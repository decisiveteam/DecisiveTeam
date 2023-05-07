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
