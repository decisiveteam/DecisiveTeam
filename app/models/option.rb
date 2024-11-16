class Option < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :decision_participant
  belongs_to :decision

  has_many :approvals, dependent: :destroy

  def set_tenant_id
    self.tenant_id ||= decision.tenant_id
  end
end
