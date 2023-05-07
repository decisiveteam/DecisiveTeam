class DecisionsController < ApplicationController

  def new
    @decision = Decision.new(team: @current_team, created_by: current_user)
  end

  def create
    other_attributes = begin
      JSON.parse(decision_params[:other_attributes] || '')
    rescue JSON::ParserError
      { notes: decision_params[:other_attributes] || '' }
    end
    @decision = Decision.new(
      team: @current_team,
      created_by: current_user,
      question: decision_params[:question],
      other_attributes: other_attributes
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
    @decision = get_decision
    render '404', status: 404 unless @decision
  end

  def options_partial
    @decision = get_decision
    render partial: 'options'
  end

  def results_partial
    @decision = get_decision
    @show_results = true
    render partial: 'results'
  end

  private

  def decision_params
    params.require(:decision).permit(:question, :other_attributes)
  end

  def get_decision
    Decision.accessible_by(current_user).find_by(
      team_id: params[:team_id],
      id: params[:id] || params[:decision_id]
    )
  end
end
