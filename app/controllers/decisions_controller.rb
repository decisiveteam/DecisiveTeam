class DecisionsController < ApplicationController

  def new
    @decision = Decision.new(
      question: params[:question],
    )
  end

  def create
    @decision = Decision.new(
      question: decision_params[:question],
      description: decision_params[:description],
      deadline: decision_params[:deadline],
    )

    if @decision.save
      redirect_to "/decisions/#{@decision.id}"
    else
      flash.now[:alert] = 'There was an error creating the decision. Please try again.'
      render :new
    end
  end

  def show
    @decision = current_decision
    return render '404', status: 404 unless @decision
    @approvals = current_approvals
    set_results_view_vars
  end

  def options_partial
    @decision = current_decision
    @approvals = current_approvals
    render partial: 'options_list_items'
  end

  def create_option_and_return_options_partial
    # TODO check for duplicate option titles
    Option.create!(
      decision: current_decision,
      decision_participant: current_decision_participant,
      title: params[:title],
      description: params[:description],
      other_attributes: {} # TODO
    )
    options_partial
  end

  def results_partial
    @decision = current_decision
    set_results_view_vars
    render partial: 'results'
  end

  private

  def decision_params
    params.require(:decision).permit(:question, :description, :status, :deadline)
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
