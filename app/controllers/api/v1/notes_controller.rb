module Api::V1
  class NotesController < BaseController
    def index
      index_not_supported_404
    end

    def create
      ActiveRecord::Base.transaction do
        note = Note.create!(
          title: params[:title],
          text: params[:text],
          deadline: params[:deadline],
          created_by: current_user,
        )
        render json: note.api_json
      rescue ActiveRecord::RecordInvalid => e
        # TODO - Detect specific validation errors and return helpful error messages
        render json: { error: 'There was an error creating the note. Please try again.' }, status: 400
      end
    end

    def update
      note = current_note
      return render json: { error: 'Note not found' }, status: 404 unless note
      updatable_attributes.each do |attribute|
        note[attribute] = params[attribute] if params.has_key?(attribute)
      end
      if note.changed?
        note.updated_by = current_user
        note.save!
      end
      render json: note.api_json
    end

    def confirm
      note = current_note
      history_event = note.confirm_read(current_user)
      render json: history_event.api_json
    end

    private

    def updatable_attributes
      [:title, :text, :deadline]
    end
  end
end
