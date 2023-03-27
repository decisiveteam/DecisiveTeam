module Api::V1
  class DecisionsController < BaseController
    def create
      decision = Decision.create!(
        team: current_team,
        decision_log: current_decision_log,
        created_by: current_user,
        context: params[:context],
        question: params[:question],
        status: params[:status],
        deadline: params[:deadline],
        external_ids: params[:external_ids],
      )
      SendWebhookJob.perform_later('https://eovsh6w1yhbr2nk.m.pipedream.net', { event: 'decision_created', data: decision })
      render json: decision
    end
  end
end
