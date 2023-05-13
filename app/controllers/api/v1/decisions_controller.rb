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

    def update
      decision = Decision.accessible_by(current_user).find_by(team_id: params[:team_id], id: params[:id])
      return render json: { error: 'Decision not found' }, status: 404 unless decision
      updatable_attributes.each do |attribute|
        decision[attribute] = params[attribute] if params.has_key?(attribute)
      end
      decision.save!
      render json: decision
    end

    private

    def updatable_attributes
      [:other_attributes, :status, :deadline]
    end
  end
end
