class AdminController < ApplicationController
  before_action :ensure_admin_user

  def admin
    @page_title = 'Admin'
    @team = @current_tenant.team
  end

  def tenant_settings
    @page_title = 'Admin Settings'
  end

  def update_tenant_settings
    @current_tenant.name = params[:name]
    @current_tenant.timezone = params[:timezone]
    ['api_enabled', 'require_login', 'allow_file_uploads'].each do |setting|
      if ['true', 'false', '1', '0'].include?(params[setting])
        @current_tenant.settings[setting] = params[setting] == 'true' || params[setting] == '1'
      end
    end
    # TODO - Home page, About page, Help page, Contact page
    @current_tenant.save!
    redirect_to "/admin"
  end

  def tenants
    return render status: 403, plain: '403 Unauthorized' unless is_main_tenant?
    @page_title = 'Tenants'
    @tenants = Tenant.all
  end

  def new_tenant
    return render status: 403, plain: '403 Unauthorized' unless is_main_tenant?
    @page_title = 'New Tenant'
  end

  def create_tenant
    return render status: 403, plain: '403 Unauthorized' unless is_main_tenant?
    t = Tenant.new
    t.subdomain = params[:subdomain]
    t.name = params[:name]
    t.save!
    t.create_main_studio!(created_by: @current_user)
    tu = t.add_user!(@current_user)
    tu.add_role!('admin')
    redirect_to "/admin/tenants/#{t.subdomain}/complete"
  end

  def complete_tenant_creation
    return render status: 403, plain: '403 Unauthorized' unless is_main_tenant?
    @tenant = Tenant.find_by(subdomain: params[:subdomain])
    @page_title = 'Complete Tenant Creation'
  end

  def show_tenant
    return render status: 403, plain: '403 Unauthorized' unless is_main_tenant?
    @showing_tenant = Tenant.find_by(subdomain: params[:subdomain])
    @current_user_is_admin_of_showing_tenant = @showing_tenant.is_admin?(@current_user)
    @page_title = @showing_tenant.name
  end

  private

  def ensure_admin_user
    unless @current_tenant.is_admin?(@current_user)
      return render status: 403, layout: 'application', html: 'You must be an admin to access this page.'
    end
  end

  def is_main_tenant?
    @current_tenant.subdomain == ENV['PRIMARY_SUBDOMAIN']
  end

  def current_resource_model
    Tenant
  end

  def current_resource
    @current_tenant
  end

end