class DecisionsController < ApplicationController

  def new
    @page_title = "Decide"
    @page_description = "Make a group decision with Harmonic Team"
    @end_of_cycle_options = Cycle.end_of_cycle_options(tempo: current_studio.tempo)
    @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
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
          deadline: params[:end_of_cycle] == '1 hour from now' ? 1.hour.from_now : Cycle.new_from_end_of_cycle_option(
            end_of_cycle: params[:end_of_cycle],
            tenant: current_tenant,
            studio: current_studio,
          ).end_date,
          created_by: current_user,
        )
        if params[:files] && @current_tenant.allow_file_uploads? && @current_studio.allow_file_uploads?
          @decision.attach!(params[:files])
        end
        if params[:pinned] == '1' && current_studio.id != current_tenant.main_studio_id
          current_studio.pin_item!(@decision)
        end
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'create',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Decision',
                id: @decision.id,
                truncated_id: @decision.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
      end
      redirect_to @decision.path
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages.each do |msg|
        flash.now[:alert] = msg
      end
      @end_of_cycle_options = Cycle.end_of_cycle_options(tempo: current_studio.tempo)
      @decision = Decision.new(
        question: decision_params[:question],
        description: decision_params[:description],
      )
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
    set_pin_vars
  end

  def options_partial
    @decision = current_decision
    @approvals = current_approvals
    render partial: 'options_list_items'
  end

  def create_option_and_return_options_partial
    ActiveRecord::Base.transaction do
      option = Option.create!(
        decision: current_decision,
        decision_participant: current_decision_participant,
        title: params[:title],
        description: params[:description],
      )
      if current_representation_session
        current_representation_session.record_activity!(
          request: request,
          semantic_event: {
            timestamp: Time.current,
            event_type: 'add_option',
            studio_id: current_studio.id,
            main_resource: {
              type: 'Decision',
              id: current_decision.id,
              truncated_id: current_decision.truncated_id,
            },
            sub_resources: [
              {
                type: 'Option',
                id: option.id,
              },
            ],
          }
        )
      end
    end
    options_partial
  end

  def results_partial
    @decision = current_decision
    set_results_view_vars
    render partial: 'results'
  end

  private

  def decision_params
    model_params.permit(
      :question, :description, :options_open,
      :duration, :duration_unit, :files
    )
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
