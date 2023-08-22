module Api::V1
  class ResultsController < BaseController    
    def index
      render json: current_decision.results
    end

    def show
      render_404
    end

    private

    def current_resource_model
      DecisionResult
    end
  end
end
