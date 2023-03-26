module Api::V1
  class DecisionsController < BaseController
    before_action :doorkeeper_authorize!
    
    def index
      # decisions = Decisions.where()
      render json: { message: 'Hello, world!' }
    end

    def create
      # decision =
      render json: params[:decision].to_json
    end
  end
end
