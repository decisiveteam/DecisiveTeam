class NoteReader
  # This model is not persisted to the database. It is used to render notes in the view.
  attr_accessor :note, :user

  def initialize(note:, user:)
    @note = note
    @user = user
  end

  def confirmed_read?
    # TODO once note editing is implemented, this will need to be updated to check for the latest read confirmation
    note.history_events.where(
      note: @note,
      user: @user,
      event_type: 'read_confirmation'
    ).any?
  end

  def name
    @user&.name || 'Anonymous'
  end
end