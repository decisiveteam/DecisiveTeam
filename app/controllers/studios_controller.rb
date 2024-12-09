class StudiosController < ApplicationController

  def show
    @page_title = @current_studio.name
    @pinned_items = @current_studio.pinned_items
    # @open_items = @current_studio.open_items
    # @recently_closed_items = @current_studio.recently_closed_items
    @backlinks = @current_studio.backlink_leaderboard
    @team = @current_studio.team
    @cycle = Cycle.new_from_tempo(tenant: @current_tenant, studio: @current_studio)
    unless @current_user.studio_user.dismissed_notices.include?('studio-welcome')
      @current_user.studio_user.dismiss_notice!('studio-welcome')
      if @current_studio.created_by == @current_user
        flash[:notice] = "Welcome to your new studio! [Click here to invite your team](#{@current_studio.url}/invite)"
      else
        flash[:notice] = "Welcome to #{@current_studio.name}! You can start creating notes, decisions, and commitments by clicking the plus icon to the right of the page header."
      end
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
        tempo: params[:tempo],
        synchronization_mode: params[:synchronization_mode],
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
    if !@current_user.studio_user.is_admin?
      return render status: 403, plain: '403 Unauthorized'
    end
    @current_studio.name = params[:name]
    # @current_studio.handle = params[:handle] if params[:handle]
    @current_studio.timezone = params[:timezone]
    @current_studio.tempo = params[:tempo]
    @current_studio.synchronization_mode = params[:synchronization_mode]
    @current_studio.settings['all_members_can_invite'] = params[:invitations] == 'all_members'
    @current_studio.settings['any_member_can_represent'] = params[:representation] == 'any_member'
    @current_studio.save!
    flash[:notice] = "Settings successfully updated. [Return to studio homepage.](#{@current_studio.url})"
    redirect_to request.referrer
  end

  def team
    @page_title = 'Studio Team'
  end

  def invite
    unless @current_user.studio_user.can_invite?
      return render layout: 'application', html: 'You do not have permission to invite members to this studio.'
    end
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
