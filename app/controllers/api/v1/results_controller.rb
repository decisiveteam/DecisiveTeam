module Api::V1
  class ResultsController < BaseController    
    def index
      render json: current_decision.results
    end
  end
end
