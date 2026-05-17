module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate!

      private

      def authenticate!
        token = request.headers["Authorization"]&.sub("Bearer ", "")
        @current_project = Project.find_by(api_key: token)
        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_project
      end

      def current_project
        @current_project
      end
    end
  end
end
