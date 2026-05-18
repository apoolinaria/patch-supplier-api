module Api
  module V1
    class FulfillmentProofsController < BaseController
      before_action :set_offset

      def create
        # Wrapping proof creation, retirement check, and payout creation in a single transaction
        # so that a failure in any step rolls back all three — no partial state persisted.
        # In a future iteration this side-effect work (handle_retirement) would move into a
        # Sidekiq job so the HTTP response isn't blocked and the worker can retry on failure.
        ApplicationRecord.transaction do
          proof = @offset.fulfillment_proofs.create!(proof_params)
          handle_retirement(@offset)
          render json: proof, status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end

      private

      def proof_params
        params.require(:fulfillment_proof).permit(:mass_g, :serial_number)
      end

      def set_offset
        @offset = current_project.offsets.find_by(id: params[:offset_id])
        render json: { error: "Offset not found" }, status: :not_found unless @offset
      end

      def handle_retirement(offset)
        retired_offset = ::RetirementService.call(offset)
        ::PayoutService.call(retired_offset) if retired_offset.retired?
      end
    end
  end
end
