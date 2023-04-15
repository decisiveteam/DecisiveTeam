module Api::V1
  class TeamsController < BaseController    
    def create
      team = Team.create!(
        handle: params[:handle],
        name: params[:name],
      )
      # Make sure the user retains access to this team.
      TeamMember.create!(
        team: team,
        user: current_user
      )
      render json: team
    end
  end
end
