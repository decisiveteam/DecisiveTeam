module Api::V1
  class OptionsController < BaseController    
    def create
      option = Option.create!(
        team: current_team,
        decision: current_decision,
        created_by: current_user,
        title: params[:title],
        description: params[:description],
        external_ids: params[:external_ids],
      )
      render json: option
    end
  end
end