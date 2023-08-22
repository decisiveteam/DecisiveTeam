module Api::V1
  class ParticipantsController < BaseController    
    def create
      participant = DecisionParticipant.create!(
        decision: current_decision,
        name: params[:name],
      )
      render json: participant
    end

    private

    def current_resource_model
      DecisionParticipant
    end

    def current_scope
      current_decision.participants
    end

    def current_resource
      current_scope.find_by(id: params[:id])
    end
  end
end