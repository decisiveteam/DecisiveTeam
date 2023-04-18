class DecisionsController < ApplicationController
  layout 'markdown'

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
      redirect_to "/teams/#{@decision.team_id}/decisions/#{@decision.number}"
    else
      flash.now[:alert] = 'There was an error creating the decision. Please try again.'
      render :new
    end
  end

  def index
    @decisions = Decision.accessible_by(current_user).where(team: @current_team)
  end

  def show
    @decision = Decision.accessible_by(current_user).find_by(team_id: params[:team_id], number: params[:number])
  end

  def options_partial
    show
    render partial: 'options'
  end

  def results_partial
    show
    @show_results = true
    render partial: 'results'
  end

  private

  def decision_params
    params.require(:decision).permit(:question, :other_attributes)
  end
end
