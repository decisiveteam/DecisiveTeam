class NotesController < ApplicationController

  def new
    @page_title = "Note"
    @page_description = "Make a note for your team"
    @end_of_cycle_options = Cycle.end_of_cycle_options(tempo: current_studio.tempo)
    @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
    @note = Note.new(
      title: params[:title],
    )
  end

  def create
    @note = Note.new(
      title: model_params[:title],
      text: model_params[:text],
      deadline: Cycle.new_from_end_of_cycle_option(
        end_of_cycle: params[:end_of_cycle],
        tenant: current_tenant,
        studio: current_studio,
      ).end_date,
      created_by: current_user,
    )
    begin
      ActiveRecord::Base.transaction do
        @note.save!
        if model_params[:files] && @current_tenant.allow_file_uploads?
          @note.attach!(model_params[:files])
        end
        @current_note = @note
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'create',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Note',
                id: @note.id,
                truncated_id: @note.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
      end
      redirect_to @note.path
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.full_messages.each do |msg|
        flash.now[:alert] = msg
      end
      @end_of_cycle_options = Cycle.end_of_cycle_options(tempo: current_studio.tempo)
      @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
      @note = Note.new(
        title: model_params[:title],
        text: model_params[:text],
      )
      render :new
    end
  end

  def show
    @note = current_note
    return render '404', status: 404 unless @note
    @page_title = @note.title
    @page_description = "Note page"
    set_pin_vars
    @note_reader = NoteReader.new(note: @note, user: current_user)
  end

  def edit
    @note = current_note
    @scratchpad_links = current_user.scratchpad_links(tenant: current_tenant, studio: current_studio)
    return render '404', status: 404 unless @note
    @page_title = "Edit Note"
    # Which cycle end date is this note deadline associated with?
  end

  def update
    @note = current_note
    return render '404', status: 404 unless @note
    @note.title = model_params[:title]
    @note.text = model_params[:text]
    # Add files to note, but don't remove existing files
    if model_params[:files]
      model_params[:files].each do |file|
        @note.files.attach(file)
      end
    end
    # @note.deadline = Cycle.new_from_end_of_cycle_option(
    #   end_of_cycle: params[:end_of_cycle],
    #   tenant: current_tenant,
    #   studio: current_studio,
    # ).end_date
    if @note.changed? || @note.files_changed?
      @note.updated_by = current_user
      ActiveRecord::Base.transaction do
        @note.save!
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'update',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Note',
                id: @note.id,
                truncated_id: @note.truncated_id,
              },
              sub_resources: [],
            }
          )
        end
      end
    end
    redirect_to @note.path
  end

  def confirm_and_return_partial
    # Must be logged in to confirm
    unless current_user
      return render message: 'You must be logged in to confirm.', status: 401
    end
    @note = current_note
    @note_reader = NoteReader.new(note: @note, user: current_user)
    ActiveRecord::Base.transaction do
      confirmation = @note.confirm_read!(current_user)
      if current_representation_session
        current_representation_session.record_activity!(
          request: request,
          semantic_event: {
            timestamp: Time.current,
            event_type: 'confirm',
            studio_id: current_studio.id,
            main_resource: {
              type: 'Note',
              id: @note.id,
              truncated_id: @note.truncated_id,
            },
            sub_resources: [{
              type: 'NoteHistoryEvent',
              id: confirmation.id,
            }],
          }
        )
      end
    end
    render partial: 'confirm'
  end

  def history_log_partial
    @note = current_note
    return render '404', status: 404 unless @note
    render partial: 'history_log'
  end

end