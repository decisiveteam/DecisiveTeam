class DecisionsController < ApplicationController

  def new
    @decision = Decision.new(
      team: @current_team,
      created_by: current_user,
      question: params[:question],
    )
  end

  def create
    @decision = Decision.new(
      team: @current_team,
      created_by: current_user,
      question: decision_params[:question],
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
    @decision = current_decision
    @approvals = current_approvals
    return render '404', status: 404 unless @decision
    @show_results = @decision.closed?
    set_results_view_vars
  end

  def options_partial
    @decision = current_decision
    @approvals = current_approvals
    render partial: 'options'
  end

  def results_partial
    @decision = current_decision
    @show_results = true
    set_results_view_vars
    render partial: 'results'
  end

  private

  def decision_params
    params.require(:decision).permit(:question, :status, :deadline)
  end

  def set_results_view_vars
    @voter_count = @decision.voter_count
    @voter_verb_phrase = if @voter_count == 1 && @decision.closed?
      "participant"
    elsif @voter_count == 1 && !@decision.closed?
      "participant has"
    elsif @voter_count != 1 && @decision.closed?
      "participants"
    elsif @voter_count != 1 && !@decision.closed?
      "participants have"
    end
  end
end
