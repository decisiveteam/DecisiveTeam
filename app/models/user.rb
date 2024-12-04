class User < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :oauth_identities
  has_many :decision_participants
  has_many :commitment_participants
  has_many :note_history_events
  has_many :tenant_users
  has_many :tenants, through: :tenant_users
  has_many :studio_users
  has_many :studios, through: :studio_users
  has_many :api_tokens
  has_many :simulated_users, class_name: 'User', foreign_key: 'parent_id'

  validate :simulated_user_must_have_parent

  def api_json
    {
      id: id,
      email: email,
      display_name: display_name,
      handle: handle,
      image_url: image_url,
      # settings: settings, # only show settings for own user
      pinned_items: pinned_items,
      created_at: created_at,
      updated_at: updated_at,
      archived_at: archived_at,
    }
  end

  def simulated_user_must_have_parent
    if parent_id.present? && simulated == false
      errors.add(:parent_id, "can only be set for simulated users")
    elsif parent_id.nil? && simulated == true
      errors.add(:parent_id, "must be set for simulated users")
    end
    if parent_id == id
      errors.add(:parent_id, "user cannot be its own parent")
    end
  end

  def can_impersonate?(user)
    user.simulated && user.parent_id == self.id && !user.archived?
  end

  def can_edit?(user)
    user == self || (user.simulated && user.parent_id == self.id)
  end

  def archive!
    self.tenant_user.archive!
  end

  def unarchive!
    self.tenant_user.unarchive!
  end

  def archived?
    self.tenant_user.archived?
  end

  def archived_at
    self.tenant_user.archived_at
  end

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

  def save_tenant_user!
    tenant_user.save!
  end

  def studio_user=(su)
    if su.user_id == self.id
      @studio_user = su
    else
      raise "studioUser user_id does not match User id"
    end
  end

  def studio_user
    @studio_user ||= studio_users.where(studio_id: Studio.current_id).first
  end

  def save_studio_user!
    studio_user.save!
  end

  def studios
    @studios ||= Studio.joins(:studio_users).where(studio_users: {user_id: id}).order('studio_users.updated_at' => :desc)
  end

  def display_name=(name)
    tenant_user.display_name = name
  end

  def display_name
    tenant_user.display_name
  end

  def handle=(handle)
    tenant_user.handle = handle
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

  def pin_item!(item)
    tenant_user.pin_item!(item)
  end

  def has_pinned?(item)
    tenant_user.has_pinned?(item)
  end

  def confirmed_read_note_events(limit: 10)
    tenant_user.confirmed_read_note_events(limit: limit)
  end

  def api_tokens
    ApiToken.where(user_id: id, tenant_id: tenant_user.tenant_id, deleted_at: nil)
  end

  def scratchpad
    tenant_user.scratchpad
  end

  def accept_invite!(studio_invite)
    if studio_invite.invited_user_id == self.id || studio_invite.invited_user_id.nil?
      StudioUser.find_or_create_by!(studio_id: studio_invite.studio_id, user_id: self.id)
      # TODO track invite accepted event
    else
      raise "Cannot accept invite for another user"
    end
  end

end