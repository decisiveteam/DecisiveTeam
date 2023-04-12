module Api::V1
  class DecisionsController < BaseController
    def create
      decision = Decision.create!(
        team: current_team,
        created_by: current_user,
        question: params[:question],
        status: params[:status],
        deadline: params[:deadline],
        other_attributes: {} # TODO
      )
      
      render json: decision
    end
  end
end
