class SequenceHistoryEvent < ApplicationRecord
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  belongs_to :sequence
  belongs_to :user
  validates :event_type, presence: true, inclusion: { in: %w(create update item_create pause resume failed_item_create) }

  def set_tenant_id
    self.tenant_id ||= sequence.tenant_id
  end

  def set_studio_id
    self.studio_id ||= sequence.studio_id
  end
end