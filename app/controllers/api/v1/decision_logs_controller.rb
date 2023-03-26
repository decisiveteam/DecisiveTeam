module Api::V1
  class DecisionLogsController < BaseController    
    def index
      render json: current_scope
    end

    def create
      decision_log = DecisionLog.create!(
        team_id: current_team.id,
        title: params[:title],
        external_ids: params[:external_ids],
      )
      render json: decision_log
    end
  end
end
