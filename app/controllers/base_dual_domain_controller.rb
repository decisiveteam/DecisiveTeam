class BaseDualDomainController < ApplicationController

  before_action :solo_domain

  def solo_domain
    raise 'Implement in subclass'
  end

  def feature_name
    raise 'Implement in subclass'
  end

  def solo_domain?
    request.domain == solo_domain
  end

  def studio_domain?
    !solo_domain? && request.path.starts_with?('/s/')
  end

  def feature_enabled?
    solo_domain? || current_studio.settings["#{feature_name}_enabled"]
  end

  def current_studio
    return @current_studio if defined?(@current_studio)
    if solo_domain?
      @current_studio ||= Studio.scope_thread_to_studio(subdomain: ENV['PRIMARY_SUBDOMAIN'], handle: nil)
    else
      super
    end
  end

  def current_tenant
    return @current_tenant if defined?(@current_tenant)
    if solo_domain?
      @current_tenant ||= current_studio.tenant
    else
      super
    end
  end

  def current_user
    return @current_user if defined?(@current_user)
    if solo_domain?
      @current_user = nil # TODO
    else
      super
    end
  end

  def current_resource_model
    Page
  end

end