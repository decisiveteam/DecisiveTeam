class NotesController < ApplicationController

  def new
    @page_title = "Note"
    @page_description = "Make a note for your team"
    @end_of_cycle_options = Cycle.end_of_cycle_options
    @scratchpad_links = [] # parse urls and filter to current studio
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
        @current_note = @note
      end
      redirect_to @note.path
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = 'There was an error creating the note. Please try again.'
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
    return render '404', status: 404 unless @note
    @page_title = "Edit Note"
    # Which cycle end date is this note deadline associated with?
  end

  def update
    @note = current_note
    return render '404', status: 404 unless @note
    @note.title = model_params[:title]
    @note.text = model_params[:text]
    # @note.deadline = Cycle.new_from_end_of_cycle_option(
    #   end_of_cycle: params[:end_of_cycle],
    #   tenant: current_tenant,
    #   studio: current_studio,
    # ).end_date
    @note.save! if @note.changed?
    redirect_to @note.path
  end

  def confirm_and_return_partial
    # Must be logged in to confirm
    unless current_user
      return render message: 'You must be logged in to confirm.', status: 401
    end
    @note = current_note
    @note_reader = NoteReader.new(note: @note, user: current_user)
    @note.confirm_read(current_user)
    render partial: 'confirm'
  end

  def history_log_partial
    @note = current_note
    return render '404', status: 404 unless @note
    render partial: 'history_log'
  end

  def edit_display_name_and_return_partial
    @note = current_note
    return render '404', status: 404 unless @note
    ActiveRecord::Base.transaction do
      @note_reader = NoteReader.new(note: @note, user: current_user)
      current_user.name = params[:name]
      current_user.save!
    end
    render partial: 'confirm'
  end

end