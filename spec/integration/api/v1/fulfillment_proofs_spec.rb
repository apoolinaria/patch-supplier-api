require "swagger_helper"

RSpec.describe "Fulfillment Proofs", type: :request do
  let(:project) { create(:project) }
  let(:offset)  { create(:offset, project: project, mass_g: 1_000_000) }
  let(:Authorization) { "Bearer #{project.api_key}" }

  path "/api/v1/offsets/{offset_id}/fulfillment_proofs" do
    parameter name: :offset_id, in: :path, type: :integer, required: true,
              description: "ID of the offset to attach the proof to"

    post "Upload a fulfillment proof for an offset" do
      tags "Fulfillment Proofs"
      consumes "application/json"
      produces "application/json"
      security [ { bearerAuth: [] } ]
      parameter name: :body, in: :body,
                schema: { "$ref" => "#/components/schemas/FulfillmentProofInput" }

      response "201", "proof created (offset may be retired and payout queued as a side effect)" do
        schema "$ref" => "#/components/schemas/FulfillmentProof"
        let(:offset_id) { offset.id }
        let(:body) do
          { fulfillment_proof: { mass_g: 500_000, serial_number: "VCS-2024-00001" } }
        end
        run_test!
      end

      response "422", "validation errors (e.g. duplicate serial number, mass exceeds remaining capacity)" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:offset_id) { offset.id }
        let(:body) do
          { fulfillment_proof: { mass_g: 0, serial_number: "" } }
        end
        run_test!
      end

      response "404", "offset not found or belongs to a different project" do
        schema "$ref" => "#/components/schemas/NotFoundResponse"
        let(:other_offset) { create(:offset) }
        let(:offset_id) { other_offset.id }
        let(:body) do
          { fulfillment_proof: { mass_g: 500_000, serial_number: "VCS-2024-00002" } }
        end
        run_test!
      end

      response "401", "invalid or missing API key" do
        schema "$ref" => "#/components/schemas/UnauthorizedResponse"
        let(:offset_id) { offset.id }
        let(:Authorization) { "Bearer wrong_key" }
        let(:body) do
          { fulfillment_proof: { mass_g: 500_000, serial_number: "VCS-2024-00003" } }
        end
        run_test!
      end
    end
  end
end
