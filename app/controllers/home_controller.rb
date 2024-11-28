class HomeController < ApplicationController

  def index
    @page_title = @current_tenant.name
    @pinned_items = @current_tenant.pinned_items
    # @open_items = @current_tenant.open_items
    # @recently_closed_items = @current_tenant.recently_closed_items
    @backlinks = @current_tenant.backlink_leaderboard
    @team = @current_tenant.team
    @current_cycles = [
      Cycle.new(name: 'today', tenant_id: @current_tenant.id),
      Cycle.new(name: 'this-week', tenant_id: @current_tenant.id),
      Cycle.new(name: 'this-month', tenant_id: @current_tenant.id),
      Cycle.new(name: 'this-year', tenant_id: @current_tenant.id),
    ]
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
