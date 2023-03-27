module Api::V1
  class TeamsController < BaseController    
    def create
      team = Team.create!(
        handle: params[:handle],
        name: params[:name],
      )
      render json: team
    end
  end
end
