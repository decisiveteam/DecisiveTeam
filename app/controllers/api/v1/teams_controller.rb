module Api::V1
  class TeamsController < BaseController
    # index and show are inherited from BaseController.
    
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
    
    def update
      team = current_team
      team.name = params[:name] if params[:name]
      team.handle = params[:handle] if params[:handle]
      team.save!
      render json: team
    end
    
    def destroy
      team = current_team
      if team.decisions.count == 0
        team.destroy!
        render json: team
      else
        render status: 400, json: {
          error: "Cannot delete a team that has decisions. You must delete all decisions first."
        }
      end
    end
  end
end
