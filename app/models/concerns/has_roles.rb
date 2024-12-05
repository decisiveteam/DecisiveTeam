module HasRoles # TenantUser, StudioUser, ...
  extend ActiveSupport::Concern

  def roles
    settings['roles'] || []
  end

  def add_roles!(roles)
    return if roles.blank?
    settings['roles'] ||= []
    settings['roles'] = settings['roles'] | roles
    save!
  end

  def add_role!(role)
    add_roles!([role])
  end

  def remove_roles!(roles)
    return if roles.blank?
    settings['roles'] ||= []
    settings['roles'] -= roles
    save!
  end

  def remove_role!(role)
    remove_roles!([role])
  end

  def has_role?(role)
    roles.include?(role)
  end

  def is_admin?
    has_role?('admin')
  end

  class_methods do
    def where_has_role(role)
      where("settings->'roles' ? :role", role: role)
    end
  end
end