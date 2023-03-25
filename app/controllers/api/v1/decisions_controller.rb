module Api::V1
  class DecisionsController < ApplicationController
    before_action :doorkeeper_authorize!
    protect_from_forgery with: :null_session

    def index
      render json: { message: 'Hello, world!' }
    end

    def create
      # decision = 
      render json: params[:decision].to_json
    end
  end
end