class HomeController < ApplicationController

  def index
    @page_title = @current_tenant.name
    @studios = @current_user.studios.where.not(id: @current_tenant.main_studio_id)
  end

  def settings
    @page_title = 'Settings'
  end

  def admin
    unless @current_tenant.is_admin?(@current_user)
      return render layout: 'application', html: 'You must be an admin to access this page.'
    end
    @page_title = 'Admin'
    @team = @current_tenant.team
  end

  def tenant_settings
    unless @current_tenant.is_admin?(@current_user)
      return render layout: 'application', html: 'You must be an admin to access this page.'
    end
    @page_title = 'Admin Settings'
  end

  def update_tenant_settings
    unless @current_tenant.is_admin?(@current_user)
      return render layout: 'application', html: 'You must be an admin to access this page.'
    end
    @current_tenant.name = params[:name]
    @current_tenant.timezone = params[:timezone]
    if ['true', 'false', '1', '0'].include?(params[:require_login])
      @current_tenant.settings['require_login'] = params[:require_login] == 'true' || params[:require_login] == '1'
    end
    # TODO - Home page, About page, Help page, Contact page
    @current_tenant.save!
    redirect_to "/admin"
  end

  def about
    @page_title = 'About'
  end

  def help
    @page_title = 'Help'
  end

  def contact
  end

  def scratchpad
    @page_title = 'Scratchpad'
    unless @current_user.tenant_user.dismissed_notices.include?('scratchpad')
      flash[:notice] = 'This is your personal scratchpad. What you write here is only visible to you. You can use your scratchpad for bookmarking links, keeping track of ideas, or anything else you want to jot down. It is always available through the top right menu.'
      @current_user.tenant_user.dismiss_notice!('scratchpad')
    end
  end

end
