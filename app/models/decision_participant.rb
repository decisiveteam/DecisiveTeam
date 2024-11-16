class DecisionParticipant < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :decision
  belongs_to :user, optional: true
  has_one :created_decision, class_name: 'Decision', foreign_key: 'created_by_id'

  has_many :approvals, dependent: :destroy
  has_many :options, dependent: :destroy

  def set_tenant_id
    self.tenant_id ||= decision.tenant_id
  end

  def authenticated?
    # If there is a user association, then we know the participant is authenticated
    user.present?
  end

  def has_dependent_resources?
    approvals.any? || options.any?
  end
end
