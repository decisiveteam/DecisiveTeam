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
      redirect_to root_path
    end
    @page_title = 'Admin'
    @team = @current_tenant.team
  end

  def about
    @page_title = 'About'
  end

  def help
    @page_title = 'Help'
  end

  def scratchpad
    @page_title = 'Scratchpad'
  end

end
