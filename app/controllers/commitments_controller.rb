class CommitmentsController < ApplicationController

  def new
    @page_title = "Commit"
    @page_description = "Start a group commitment"
    @end_of_cycle_options = Cycle.end_of_cycle_options(tempo: current_studio.tempo)
    @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
    @commitment = Commitment.new(
      title: params[:title],
    )
  end

  def create
    @commitment = Commitment.new(
      title: model_params[:title],
      description: model_params[:description],
      critical_mass: model_params[:critical_mass],
      deadline: params[:end_of_cycle] == '1 hour from now' ? 1.hour.from_now : Cycle.new_from_end_of_cycle_option(
        end_of_cycle: params[:end_of_cycle],
        tenant: current_tenant,
        studio: current_studio,
      ).end_date,
      created_by: current_user,
    )
    begin
      ActiveRecord::Base.transaction do
        @commitment.save!
        if params[:files] && @current_tenant.allow_file_uploads? && @current_studio.allow_file_uploads?
          @commitment.attach!(params[:files])
        end
        @current_commitment = @commitment
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'create',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Commitment',
                id: @commitment.id,
                truncated_id: @commitment.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
      end
      redirect_to @commitment.path
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = 'There was an error creating the commitment. Please try again.'
      render :new
    end
  end

  def show
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    @commitment_participant = current_commitment_participant
    if current_user
      @commitment_participant_name = @commitment_participant.name || current_user.name
    else
      @commitment_participant_name = @commitment_participant.name
    end
    @participants_list_limit = 10
    @page_title = @commitment.title
    @page_description = "Coordinate with your team"
    set_pin_vars
  end

  def status_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    render partial: 'status'
  end

  def join_and_return_partial
    # Must be logged in to join
    unless current_user
      return render message: 'You must be logged in to join.', status: 401
    end
    @commitment = current_commitment
    if @commitment.closed?
      return render message: 'This commitment is closed.', status: 400
    end
    @commitment_participant = current_commitment_participant
    @commitment_participant_name = @commitment_participant.name || current_user.name
    @commitment_participant.committed = true if params[:committed].to_s == 'true'
    @commitment_participant.name = @commitment_participant_name
    ActiveRecord::Base.transaction do
      @commitment_participant.save!
      if current_representation_session
        current_representation_session.record_activity!(
          request: request,
          semantic_event: {
            timestamp: Time.current,
            event_type: 'commit',
            studio_id: current_studio.id,
            main_resource: {
              type: 'Commitment',
              id: @commitment.id,
              truncated_id: @commitment.truncated_id,
            },
            sub_resources: [
              {
                type: 'CommitmentParticipant',
                id: @commitment_participant.id,
              }
            ],
          }
        )
      end
    end
    render partial: 'join'
  end

  def participants_list_items_partial
    @commitment = current_commitment
    return render '404', status: 404 unless @commitment
    @participants_list_limit = params[:limit].to_i if params[:limit].present?
    @participants_list_limit = 20 if @participants_list_limit < 1
    render partial: 'participants_list_items'
  end

  private

  def current_app
    return @current_app if defined?(@current_app)
    @current_app = 'coordinated'
    @current_app_title = 'Coordinated Team'
    @current_app_description = 'fast group coordination'
    @current_app
  end
end
