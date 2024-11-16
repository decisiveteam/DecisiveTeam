class Approval < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :option
  belongs_to :decision
  belongs_to :decision_participant

  validates :value, inclusion: { in: [0, 1] }
  validates :stars, inclusion: { in: [0, 1] }

  def set_tenant_id
    self.tenant_id ||= option.tenant_id
  end
end
