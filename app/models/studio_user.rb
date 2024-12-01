class StudioUser < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  belongs_to :studio
  belongs_to :user

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

end
