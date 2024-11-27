class DecisionsController < ApplicationController

  def new
    @page_title = "Decide"
    @page_description = "Make a group decision with Harmonic Team"
    @decision = Decision.new(
      question: params[:question],
    )
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @decision = @current_decision = Decision.create!(
          question: decision_params[:question],
          description: decision_params[:description],
          options_open: decision_params[:options_open],
          deadline: Time.now + duration_param,
          created_by: current_user,
        )
      end
      redirect_to @decision.path
    rescue ActiveRecord::RecordInvalid => e
      # TODO - Detect specific validation errors and return helpful error messages
      flash.now[:alert] = 'There was an error creating the decision. Please try again.'
      render :new
    end
  end

  def show
    @decision = current_decision
    return render '404', status: 404 unless @decision
    @participant = current_decision_participant
    @page_title = @decision.question
    @page_description = "Decide as a group with Harmonic Team"

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
    params.require(:decision).permit(:question, :description, :options_open, :duration, :duration_unit)
  end

  def set_results_view_vars
    @view_count = @decision.view_count
    @option_contributor_count = @decision.option_contributor_count
    @voter_count = @decision.voter_count
  end

  def current_app
    return @current_app if defined?(@current_app)
    @current_app = 'decisive'
    @current_app_title = 'Harmonic Team'
    @current_app_description = 'fast group decision-making'
    @current_app
  end
end
