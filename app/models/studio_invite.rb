class StudioInvite < ApplicationRecord
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  belongs_to :created_by, class_name: 'User'
  belongs_to :invited_user, class_name: 'User', optional: true

  def self.set_tenant_id
    self.tenant_id ||= created_by.tenant_id
  end

  def self.set_studio_id
    self.studio_id ||= Studio.current_id
  end

  def shareable_link
    if invited_user
      nil # Invites for a specific user cannot be shared. The user must log in.
    elsif code
      "#{studio.url}/join?code=#{code}"
    else
      raise 'Unexpected invite state.'
    end
  end

end