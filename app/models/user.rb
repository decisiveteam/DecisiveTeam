class User < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :oauth_identities
  has_many :decision_participants
  has_many :commitment_participants
  has_many :note_history_events
  has_many :tenant_users
  has_many :tenants, through: :tenant_users

  def tenant_user=(tu)
    if tu.user_id == self.id
      @tenant_user = tu
    else
      raise "TenantUser user_id does not match User id"
    end
  end

  def tenant_user
    @tenant_user ||= tenant_users.where(tenant_id: Tenant.current_id).first
  end

  def display_name
    tenant_user.display_name
  end

  def handle
    tenant_user.handle
  end

  def path
    tenant_user.path
  end

  def settings
    tenant_user.settings
  end

  def pinned_items
    tenant_user.pinned_items
  end

  def confirmed_read_note_events(limit: 10)
    tenant_user.confirmed_read_note_events(limit: limit)
  end
end