class CustomDataAssociation < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :parent_record, class_name: 'CustomDataRecord'
  belongs_to :child_record, class_name: 'CustomDataRecord'

  validates :parent_record, presence: true
  validates :child_record, presence: true

  validate :all_records_belong_to_same_tenant

  def set_tenant_id
    self.tenant_id ||= parent_record.tenant_id
  end

  def all_records_belong_to_same_tenant
    unless parent_record.tenant_id == child_record.tenant_id && parent_record.tenant_id == tenant_id
      errors.add(:tenant_id, "must match parent_record and child_record tenant_id")
    end
  end
end