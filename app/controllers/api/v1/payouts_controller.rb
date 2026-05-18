module Api
  module V1
    class PayoutsController < BaseController
      def index
        payouts = current_project.payouts.includes(:offset).order(:created_at)
        render json: {
          project_id: current_project.id,
          payouts: payouts.map { |p| payout_json(p) }
        }
      end

      private

      def payout_json(payout)
        {
          id: payout.id,
          offset_id: payout.offset_id,
          offset_name: payout.offset.name,
          amount_cents_usd: payout.amount_cents_usd,
          status: payout.status,
          created_at: payout.created_at
        }
      end
    end
  end
end
