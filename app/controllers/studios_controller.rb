class StudiosController < ApplicationController

  def show
    @page_title = @current_studio.name
    @pinned_items = @current_studio.pinned_items
    # @open_items = @current_studio.open_items
    # @recently_closed_items = @current_studio.recently_closed_items
    @backlinks = @current_studio.backlink_leaderboard
    @team = @current_studio.team
    # Start with today, then zoom out until we have significant data increase or we reach this year
    @cycle = Cycle.new(name: 'today', tenant: @current_tenant, studio: @current_studio)
    if @cycle.total_count < 3
      this_week = Cycle.new(name: 'this-week', tenant: @current_tenant, studio: @current_studio)
      @cycle = this_week if this_week.total_count > @cycle.total_count
    end
    if @cycle.total_count < 3
      this_month = Cycle.new(name: 'this-month', tenant: @current_tenant, studio: @current_studio)
      @cycle = this_month if this_month.total_count > @cycle.total_count
    end
    if @cycle.total_count < 3
      this_year = Cycle.new(name: 'this-year', tenant: @current_tenant, studio: @current_studio)
      @cycle = this_year if this_year.total_count > @cycle.total_count
    end
  end

  def new
  end

  def handle_available
    render json: { available: Studio.handle_available?(params[:handle]) }
  end

  def create
    ActiveRecord::Base.transaction do
      @studio = Studio.create!(
        name: params[:name],
        handle: params[:handle],
        created_by: @current_user,
        timezone: params[:timezone],
      )
      @studio.add_user!(@current_user, roles: ['admin', 'representative'])
      @studio.create_welcome_note!
    end
    redirect_to @studio.path
  end

  def settings
    if @current_user.studio_user.is_admin?
      @page_title = 'Studio Settings'
    else
      return render layout: 'application', html: 'You must be an admin to access studio settings.'
    end
  end

  def update_settings
    # TODO - only allow admins to update settings
    @current_studio.name = params[:name]
    # @current_studio.handle = params[:handle] if params[:handle]
    @current_studio.timezone = params[:timezone]
    if ['true', 'false', '1', '0'].include?(params[:pages_enabled])
      @current_studio.settings['pages_enabled'] = params[:pages_enabled] == 'true' || params[:pages_enabled] == '1'
    end
    if ['true', 'false', '1', '0'].include?(params[:random_enabled])
      @current_studio.settings['random_enabled'] = params[:random_enabled] == 'true' || params[:random_enabled] == '1'
    end
    @current_studio.save!
    redirect_to @current_studio.path
  end

  def team
    @page_title = 'Studio Team'
  end

  def invite
    @page_title = 'Invite to Studio'
    @invite = @current_studio.find_or_create_shareable_invite(@current_user)
  end

  def join
    if current_user && current_user.studios.include?(@current_studio)
      @current_user_is_member = true
      return
    end
    invite = StudioInvite.find_by(code: params[:code]) if params[:code]
    invite ||= StudioInvite.find_by(invited_user: current_user, studio: @current_studio)
    if invite && current_user
      if invite.studio == @current_studio
        @invite = invite
      else
        return render plain: '404 invite code not found', status: 404
      end
    elsif invite && !current_user
      redirect_to "/login?code=#{invite.code}"
    end
  end

  def accept_invite
    if current_user && current_user.studios.include?(@current_studio)
      return render status: 400, text: 'You are already a member of this studio'
    end
    invite = StudioInvite.find_by(code: params[:code]) if params[:code]
    invite ||= StudioInvite.find_by(invited_user: current_user, studio: @current_studio)
    if invite && current_user
      if invite.studio == @current_studio
        @current_user.accept_invite!(invite)
        redirect_to @current_studio.path
      else
        return render plain: '404 invite code not found', status: 404
      end
    elsif invite && !current_user
      redirect_to "/login?code=#{invite.code}"
    else
      # TODO - check studio settings to see if public join is allowed
      return render plain: '404 invite code not found', status: 404
    end
  end

  def leave
  end


end
