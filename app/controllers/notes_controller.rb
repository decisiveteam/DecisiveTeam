class NotesController < ApplicationController

  def new
    @page_title = "Note"
    @page_description = "Add a note for your team"
    @note = Note.new(
      title: params[:title],
    )
  end

  def create
    @note = Note.new(
      title: model_params[:title],
      text: model_params[:text],
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
  end
end