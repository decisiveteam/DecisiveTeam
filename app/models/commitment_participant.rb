class CommitmentParticipant < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :commitment
  belongs_to :user, optional: true
  # TODO
  # has_one :created_decision, class_name: 'Commitment', foreign_key: 'created_by_id'

  def set_tenant_id
    self.tenant_id ||= commitment.tenant_id
  end

  def authenticated?
    # If there is a user association, then we know the participant is authenticated
    user.present?
  end

  def has_dependent_resources?
    false
  end

  def committed?
    committed_at.present?
  end

  def committed
    committed?
  end

  def committed=(value)
    if value == '1' || value == 'true' || value == true
      self.committed_at = Time.current unless committed?
    elsif value == '0' || value == 'false' || value == false
      self.committed_at = nil
    else
      raise 'Invalid value for committed'
    end
  end
end
