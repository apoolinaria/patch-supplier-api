require "rails_helper"

RSpec.describe "Api::V1::Offsets", type: :request do
  let(:project) { create(:project) }
  let(:headers) { { "Authorization" => "Bearer #{project.api_key}" } }

  describe "POST /api/v1/projects/:project_id/offsets" do
    let(:valid_params) { { offset: { name: "Test Offset", mass_g: 5_000_000, price_cents_usd: 100_000 } } }

    it "creates an offset for the authenticated project" do
      expect {
        post "/api/v1/projects/#{project.id}/offsets", params: valid_params, headers: headers
      }.to change(Offset, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["project_id"]).to eq(project.id)
    end

    it "auto-generates a sku from the name" do
      post "/api/v1/projects/#{project.id}/offsets", params: valid_params, headers: headers
      expect(JSON.parse(response.body)["sku"]).to include("test-offset")
    end

    it "rejects mass_g of 0" do
      post "/api/v1/projects/#{project.id}/offsets",
           params: { offset: valid_params[:offset].merge(mass_g: 0) },
           headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 401 with missing token" do
      post "/api/v1/projects/#{project.id}/offsets", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with invalid token" do
      post "/api/v1/projects/#{project.id}/offsets",
           params: valid_params,
           headers: { "Authorization" => "Bearer invalid" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/projects/:project_id/offsets" do
    it "returns only the authenticated project's offsets" do
      create_list(:offset, 2, project: project)
      create(:offset)

      get "/api/v1/projects/#{project.id}/offsets", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(2)
    end
  end
end
