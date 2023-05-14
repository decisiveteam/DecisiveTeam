class TeamsController < ApplicationController

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    if @team.save
      TeamMember.create!(user: current_user, team: @team)
      redirect_to "/teams/#{@team.id}"
    else
      flash.now[:alert] = 'There was an error creating the team. Please try again.'
      render :new
    end
  end

  def invite
    @team = Team.accessible_by(current_user).find(params[:team_id])
    # TODO Consider not generating a new code if there is already an unused one
    @invite_code = @team.generate_invite_code(
      created_by: current_user,
      expires_at: 1.month.from_now,
      max_uses: params[:max_uses] || 10
    )
  end

  def join
    @invite = TeamInvite.find_by(team_id: params[:team_id], code: params[:invite_code])
    @team = @invite.team if @invite
  end

  def confirm_invite
    return redirect_to '/login' unless current_user
    invite = TeamInvite.find_by(team_id: params[:team_id], code: params[:invite_code])
    return redirect_to '/teams' unless invite
    invite.assert_valid!
    already_member = TeamMember.find_by(team: invite.team, user: current_user)
    unless already_member
      TeamMember.create!(user: current_user, team: invite.team)
      invite.use!
    end
    redirect_to "/teams/#{invite.team.id}"
  end

  def index
    @teams = Team.accessible_by(current_user)
  end

  def show
    @team = Team.accessible_by(current_user).find(params[:id])
  end

  private

  def team_params
    params.require(:team).permit(:name, :handle)
  end
end
