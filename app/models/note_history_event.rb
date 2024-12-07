class NoteHistoryEvent < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :note
  belongs_to :user, optional: true
  validates :event_type, presence: true, inclusion: { in: %w(create update read_confirmation) }
  validates :happened_at, presence: true

  def set_tenant_id
    self.tenant_id ||= note.tenant_id
  end

  def description
    case event_type
    when 'create'
      'Note created'
    when 'update'
      'Note updated'
    when 'read_confirmation'
      "#{user.name} confirmed reading this note"
    else
      raise 'Unknown event type'
    end
  end
end