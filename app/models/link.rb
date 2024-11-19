class Link < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id

  belongs_to :from_linkable, polymorphic: true
  belongs_to :to_linkable, polymorphic: true

  def set_tenant_id
    return unless self.tenant_id.nil?
    from_tenant_id = from_linkable.tenant_id
    to_tenant_id = to_linkable.tenant_id
    if from_tenant_id != to_tenant_id
      errors.add(:base, "Cannot link objects from different tenants")
    end
    self.tenant_id = from_tenant_id
  end
end