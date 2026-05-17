require "rails_helper"

RSpec.describe "Api::V1::Payouts", type: :request do
  let(:project) { create(:project) }
  let(:offset)  { create(:offset, project: project) }
  let(:headers) { { "Authorization" => "Bearer #{project.api_key}" } }

  describe "GET /api/v1/projects/:project_id/payouts" do
    it "returns payouts scoped to the authenticated project" do
      create(:payout, project: project, offset: offset)
      create(:payout)

      get "/api/v1/projects/#{project.id}/payouts", headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["project_id"]).to eq(project.id)
      expect(body["payouts"].length).to eq(1)
    end

    it "includes name and amount in the response" do
      create(:payout, project: project, offset: offset, amount_cents_usd: 300_000)

      get "/api/v1/projects/#{project.id}/payouts", headers: headers

      payout_json = JSON.parse(response.body)["payouts"].first
      expect(payout_json["amount_cents_usd"]).to eq(300_000)
      expect(payout_json["offset_name"]).to eq(offset.name)
      expect(payout_json["status"]).to eq("pending_approval")
    end

    it "returns 401 with missing token" do
      get "/api/v1/projects/#{project.id}/payouts"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
