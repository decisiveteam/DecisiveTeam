class CustomDataHistoryEvent < ActiveRecord::Base
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  belongs_to :custom_data_record
  belongs_to :user

  validates :event_type, presence: true, inclusion: { in: %w(create read update delete) }

  def set_tenant_id
    self.tenant_id ||= custom_data_record.tenant_id
  end

  def set_studio_id
    self.studio_id ||= custom_data_record.studio_id
  end

  def api_json(include: [])
    {
      id: id,
      custom_data_record_id: custom_data_record_id,
      user_id: user_id,
      happened_at: happened_at,
      event_type: event_type,
      event_data: event_data,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
end