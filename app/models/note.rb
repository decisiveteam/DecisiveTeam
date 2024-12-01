class Note < ApplicationRecord
  include Tracked
  include Linkable
  include Pinnable
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by_id'
  has_many :note_history_events, dependent: :destroy
  validates :title, presence: true

  after_create do
    # TODO Reference user who created the note
    NoteHistoryEvent.create!(
      note: self,
      user: self.created_by,
      event_type: 'create',
      happened_at: self.created_at,
    )
  end

  after_update do
    # TODO Reference user who updated the note and include versioning
    NoteHistoryEvent.create!(
      note: self,
      user: self.updated_by,
      event_type: 'update',
      happened_at: self.updated_at
    )
  end

  def truncated_id
    # TODO Fix the bug that causes this to be nil on first save
    super || self.id.to_s[0..7]
  end

  def api_json(include: [])
    response = {
      id: id,
      truncated_id: truncated_id,
      title: title,
      text: text,
      deadline: deadline,
      confirmed_reads: note_history_events.where(event_type: 'read_confirmation').count,
      created_at: created_at,
      updated_at: updated_at,
      created_by_id: created_by_id,
      updated_by_id: updated_by_id,
    }
    if include.include?('history_events')
      response.merge!({ history_events: history_events.map(&:api_json) })
    end
    if include.include?('backlinks')
      response.merge!({ backlinks: backlinks.map(&:api_json)})
    end
    response
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

  def user_has_read?(user)
    note_history_events.where(
      user: user,
      event_type: 'read_confirmation'
    ).exists?
  end
end