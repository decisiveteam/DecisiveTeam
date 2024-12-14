class SequencesController < ApplicationController

  def new
    @page_title = "Sequence"
    @page_description = "Start a sequence of notes, decisions, or commitments"
    @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
    @sequence = Sequence.new
  end

  def create
    @sequence = Sequence.new(
      title: params[:title],
      description: params[:description],
      item_type: params[:item_type],
      created_by: current_user,
      settings: {
        cycle_unit: 'week', # only supported option for now
        cycle_subunit: 'day',
        cycle_pattern: pattern_from_params,
        template: {
          # options_open: params[:options_open] == '1',
          # options: params[:options],
          # deadline_offset: params[:deadline_offset],
          # critical_mass: params[:critical_mass],
        },
      }
    )
    if params[:understand] != '1'
      flash.now[:alert] = "You must confirm that you understand before creating a sequence."
      @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
      return render :new
    end
    begin
      ActiveRecord::Base.transaction do
        @sequence.save!
        @current_sequence = @sequence
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'create',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Sequence',
                id: @sequence.id,
                truncated_id: @sequence.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
      end
      redirect_to @sequence.path
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages.each do |msg|
        flash.now[:alert] = msg
      end
      @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
      render :new
    end
  end

  def show
    @sequence = current_sequence
    return render '404', status: 404 unless @sequence
    @page_title = @sequence.title
    @page_description = "Sequence #{@sequence.truncated_id}"
    set_pin_vars
  end

  private

  def current_resource_model
    Sequence
  end

  def current_resource
    current_sequence
  end

  def pattern_from_params
    [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday
    ].map do |day|
      params[day] == '1' ? day : nil
    end.compact
  end

end