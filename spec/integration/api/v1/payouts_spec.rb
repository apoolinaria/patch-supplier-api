require "swagger_helper"

RSpec.describe "Payouts", type: :request do
  let(:project) { create(:project) }
  let(:Authorization) { "Bearer #{project.api_key}" }

  path "/api/v1/projects/{project_id}/payouts" do
    parameter name: :project_id, in: :path, type: :integer, required: true,
              description: "ID of the authenticated project"

    get "List all payouts for the project" do
      tags "Payouts"
      produces "application/json"
      security [ { bearerAuth: [] } ]

      response "200", "payouts returned" do
        schema "$ref" => "#/components/schemas/PayoutList"

        let(:project_id) { project.id }
        let(:offset) { create(:offset, project: project, retired: true) }
        before { create(:payout, project: project, offset: offset) }

        run_test!
      end

      response "401", "invalid or missing API key" do
        schema "$ref" => "#/components/schemas/UnauthorizedResponse"
        let(:project_id) { project.id }
        let(:Authorization) { "Bearer wrong_key" }
        run_test!
      end
    end
  end
end
