module Api::V1
  class WebhooksController < BaseController    
    def create
      webhook = Webhook.create!(
        team: current_team,
        decision_log: current_decision_log,
        decision: current_decision,
        created_by: current_user,
        url: params[:url],
        event: params[:event],
      )
      render json: webhook
    end

    def destroy
      webhook = current_resource
      webhook.destroy!
      render json: webhook
    end
  end
end