module Api::V1
  class DecisionsController < BaseController
    def index
      render json: current_scope.all
    end

    def create
      # decision =
      render json: params[:decision].to_json
    end
  end
end
