class StudiosController < ApplicationController

  def show
    @page_title = @current_studio.name
    @pinned_items = @current_studio.pinned_items
    # @open_items = @current_studio.open_items
    # @recently_closed_items = @current_studio.recently_closed_items
    @backlinks = @current_studio.backlink_leaderboard
    @team = @current_studio.team
    @current_cycles = ['today', 'this-week', 'this-month', 'this-year'].map do |name|
      Cycle.new(name: name, tenant: @current_tenant, studio: @current_studio)
    end
  end

  def new
  end

  def handle_available
    render json: { available: Studio.handle_available?(params[:handle]) }
  end

  def create
    @studio = Studio.new(
      name: params[:name],
      handle: params[:handle],
    )
    @studio.save!
    @studio.add_user!(@current_user)
    redirect_to @studio.path
  end

  def settings
    @page_title = 'Studio Settings'
  end

  def team
    @page_title = 'Studio Team'
  end

  def invite
    @page_title = 'Invite to Studio'
    @invite = @current_studio.find_or_create_shareable_invite(@current_user)
  end

  def join
    invite = StudioInvite.find_by(code: params[:code]) if params[:code]
    if invite && current_user
      if invite && invite.studio == @current_studio
        @current_user.accept_invite!(invite)
        redirect_to @current_studio.path
      else
        return render '404', status: 404
      end
    elsif invite && !current_user
      redirect_to "/login?code=#{invite.code}"
    else
      return render text: '...' # TODO
    end
  end

end
