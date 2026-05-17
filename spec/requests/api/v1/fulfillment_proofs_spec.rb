require "rails_helper"

RSpec.describe "Api::V1::FulfillmentProofs", type: :request do
  let(:project) { create(:project) }
  let(:offset)  { create(:offset, project: project, mass_g: 10_000_000, price_cents_usd: 300_000) }
  let(:headers) { { "Authorization" => "Bearer #{project.api_key}" } }

  describe "POST /api/v1/offsets/:offset_id/fulfillment_proofs" do
    context "partial proof — offset not yet fully retired" do
      before { create(:order, offset: offset, mass_g: 10_000_000) }

      it "creates the proof but does not retire the offset or create a payout" do
        post "/api/v1/offsets/#{offset.id}/fulfillment_proofs",
             params: { fulfillment_proof: { mass_g: 5_000_000, serial_number: "PARTIAL-001" } },
             headers: headers

        expect(response).to have_http_status(:created)
        expect(offset.reload.retired?).to be false
        expect(Payout.count).to eq(0)
      end
    end

    context "exact-fill proof — retires offset and creates payout" do
      before { create(:order, offset: offset, mass_g: 10_000_000) }

      it "marks the offset retired and creates a pending_approval payout" do
        post "/api/v1/offsets/#{offset.id}/fulfillment_proofs",
             params: { fulfillment_proof: { mass_g: 10_000_000, serial_number: "FULL-001" } },
             headers: headers

        expect(response).to have_http_status(:created)
        expect(offset.reload.retired?).to be true
        expect(Payout.count).to eq(1)
        expect(Payout.last.amount_cents_usd).to eq(300_000)
        expect(Payout.last.status).to eq("pending_approval")
      end
    end

    context "cumulative proofs reaching full mass" do
      before { create(:order, offset: offset, mass_g: 10_000_000) }

      it "retires on the proof that fills remaining capacity" do
        post "/api/v1/offsets/#{offset.id}/fulfillment_proofs",
             params: { fulfillment_proof: { mass_g: 6_000_000, serial_number: "CUM-001" } },
             headers: headers
        expect(offset.reload.retired?).to be false

        post "/api/v1/offsets/#{offset.id}/fulfillment_proofs",
             params: { fulfillment_proof: { mass_g: 4_000_000, serial_number: "CUM-002" } },
             headers: headers
        expect(offset.reload.retired?).to be true
        expect(Payout.count).to eq(1)
      end
    end

    it "rejects a proof that exceeds remaining capacity" do
      post "/api/v1/offsets/#{offset.id}/fulfillment_proofs",
           params: { fulfillment_proof: { mass_g: 20_000_000, serial_number: "OVER-001" } },
           headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 404 for an offset belonging to another project" do
      other_offset = create(:offset)

      post "/api/v1/offsets/#{other_offset.id}/fulfillment_proofs",
           params: { fulfillment_proof: { mass_g: 1_000_000, serial_number: "CROSS-001" } },
           headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 401 with missing token" do
      post "/api/v1/offsets/#{offset.id}/fulfillment_proofs",
           params: { fulfillment_proof: { mass_g: 1_000_000, serial_number: "AUTH-001" } }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
