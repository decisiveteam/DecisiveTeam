class User < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :decision_participants
  has_many :commitment_participants
  has_many :note_history_events
  has_many :tenant_users
  has_many :tenants, through: :tenant_users

  def tenant_user=(tu)
    if tu.user_id == self.id
      @tenant_user = tu
    else
      raise
    end
  end

  def tenant_user
    @tenant_user ||= tenant_users.where(tenant_id: Tenant.current_id)
  end

  def display_name
    tenant_user.display_name
  end

  def handle
    tenant_user.handle
  end

  def settings
    tenant_user.settings
  end
end