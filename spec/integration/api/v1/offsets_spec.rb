require "swagger_helper"

RSpec.describe "Offsets", type: :request do
  let(:project) { create(:project) }
  let(:Authorization) { "Bearer #{project.api_key}" }

  path "/api/v1/projects/{project_id}/offsets" do
    parameter name: :project_id, in: :path, type: :integer, required: true,
              description: "ID of the authenticated project"

    get "List all offsets for the project" do
      tags "Offsets"
      produces "application/json"
      security [ { bearerAuth: [] } ]

      response "200", "offsets returned" do
        schema type: :array, items: { "$ref" => "#/components/schemas/Offset" }
        let(:project_id) { project.id }
        run_test!
      end

      response "401", "invalid or missing API key" do
        schema "$ref" => "#/components/schemas/UnauthorizedResponse"
        let(:project_id) { project.id }
        let(:Authorization) { "Bearer wrong_key" }
        run_test!
      end
    end

    post "Create a new offset for the project" do
      tags "Offsets"
      consumes "application/json"
      produces "application/json"
      security [ { bearerAuth: [] } ]
      parameter name: :body, in: :body, schema: { "$ref" => "#/components/schemas/OffsetInput" }

      response "201", "offset created" do
        schema "$ref" => "#/components/schemas/Offset"
        let(:project_id) { project.id }
        let(:body) do
          { offset: { name: "My New Offset", mass_g: 2_000_000, price_cents_usd: 100_000 } }
        end
        run_test!
      end

      response "422", "validation errors" do
        schema "$ref" => "#/components/schemas/ErrorResponse"
        let(:project_id) { project.id }
        let(:body) { { offset: { name: "" } } }
        run_test!
      end

      response "401", "invalid or missing API key" do
        schema "$ref" => "#/components/schemas/UnauthorizedResponse"
        let(:project_id) { project.id }
        let(:Authorization) { "Bearer wrong_key" }
        let(:body) { { offset: { name: "x", mass_g: 1, price_cents_usd: 1 } } }
        run_test!
      end
    end
  end
end
