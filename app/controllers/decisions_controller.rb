class DecisionsController < ApplicationController

  def new
    @page_title = "Make a Decision"
    @page_description = "Decide as a group with Decisive Team"
    @decision = Decision.new(
      question: params[:question],
    )
  end

  def create
    @decision = Decision.new(
      question: decision_params[:question],
      description: decision_params[:description],
      options_open: decision_params[:options_open],
      deadline: Time.now + duration_param,
      auth_required: decision_params[:auth_required],
    )
    begin
      ActiveRecord::Base.transaction do
        @decision.save!
        @current_decision = @decision
        @current_decision.created_by = current_decision_participant
        @current_decision.save!
      end
      redirect_to @decision.path
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = 'There was an error creating the decision. Please try again.'
      render :new
    end
  end

  def show
    @decision = current_decision
    return render '404', status: 404 unless @decision
    @participant = current_decision_participant
    @page_title = @decision.question
    @page_description = "Decide as a group with Decisive Team"

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

  def duration_param
    duration = decision_params[:duration].to_i
    duration_unit = decision_params[:duration_unit] || 'hour(s)'
    case duration_unit
    when 'minute(s)'
      duration.minutes
    when 'hour(s)'
      duration.hours
    when 'day(s)'
      duration.days
    when 'week(s)'
      duration.weeks
    else
      raise "Unknown duration_unit: #{duration_unit}"
    end
  end

  def decision_params
    params.require(:decision).permit(:question, :description, :options_open, :duration, :duration_unit, :auth_required)
  end

  def set_results_view_vars
    @view_count = @decision.view_count
    @option_contributor_count = @decision.option_contributor_count
    @voter_count = @decision.voter_count
  end
end
