class StudioUser < ApplicationRecord
  include HasRoles
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  belongs_to :studio
  belongs_to :user

  validate :trustee_users_not_member_of_main_studio

  def trustee_users_not_member_of_main_studio
    if user.trustee? && studio == tenant.main_studio
      errors.add(:user, "Trustee users cannot be members of the main studio")
    end
  end

  def user
    @user ||= super
    @user.studio_user ||= self
    @user
  end

  # def archive!
  #   self.archived_at = Time.current
  #   save!
  # end

  # def unarchive!
  #   self.archived_at = nil
  #   save!
  # end

  # def archived?
  #   self.archived_at.present?
  # end

  def confirmed_read_note_events(limit: 10)
    NoteHistoryEvent.where(
      tenant_id: tenant_id,
      studio_id: studio_id,
      user_id: user_id,
      event_type: 'read_confirmation',
    ).includes(:note).order(happened_at: :desc).limit(limit)
  end

  def can_invite?
    has_role?('admin') || studio.allow_invites?
  end

end
