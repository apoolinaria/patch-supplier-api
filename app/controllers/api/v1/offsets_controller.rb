module Api
  module V1
    class OffsetsController < BaseController
      def index
        offsets = current_project.offsets.order(:created_at)
        render json: offsets
      end

      def create
        offset = current_project.offsets.build(offset_params)

        if offset.save
          render json: offset, status: :created
        else
          render json: { errors: offset.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def offset_params
        params.require(:offset).permit(:name, :mass_g, :price_cents_usd, :sku)
      end
    end
  end
end
