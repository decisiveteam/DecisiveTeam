class DecisionsController < ApplicationController
  layout 'markdown'
  before_action :set_current_team # Decision paths should always be scoped by team

  def new
    @decision = Decision.new(team: @current_team, created_by: current_user)
  end

  def create
    @decision = Decision.new(
      team: @current_team,
      created_by: current_user,
      question: decision_params[:question],
      other_attributes: JSON.parse(decision_params[:other_attributes])
    )

    if @decision.save
      redirect_to "/teams/#{@decision.team_id}/decisions/#{@decision.id}"
    else
      flash.now[:alert] = 'There was an error creating the decision. Please try again.'
      render :new
    end
  end

  def index
    @decisions = Decision.accessible_by(current_user).where(team: @current_team)
  end

  def show
    @decision = Decision.accessible_by(current_user).find(params[:id])
  end

  private

  def set_current_team
    @current_team = Team.accessible_by(current_user).find(params[:team_id])
  end

  def decision_params
    params.require(:decision).permit(:question, :other_attributes)
  end
end
