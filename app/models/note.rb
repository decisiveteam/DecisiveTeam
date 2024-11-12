class Note < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  has_many :note_history_events, dependent: :destroy
  validates :title, presence: true

  after_create do
    # TODO Reference user who created the note
    NoteHistoryEvent.create!(
      note: self,
      user: nil,
      event_type: 'create',
      happened_at: self.created_at
    )
  end

  after_update do
    # TODO Reference user who updated the note and include versioning
    NoteHistoryEvent.create!(
      note: self,
      user: nil,
      event_type: 'update',
      happened_at: self.updated_at
    )
  end

  def truncated_id
    # TODO Fix the bug that causes this to be nil on first save
    super || self.id.to_s[0..7]
  end

  def path_prefix
    'n'
  end

  def history_events
    note_history_events
  end

  def confirm_read(user)
    NoteHistoryEvent.create!(
      note: self,
      user: user,
      event_type: 'read_confirmation',
      happened_at: Time.current
    )
  end
end