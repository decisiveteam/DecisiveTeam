module Api::V1
  class ApprovalsController < BaseController
    def create
      approval_id = Approval.upsert({
        team_id: current_team.id,
        decision_id: current_decision.id,
        option_id: current_option.id,
        created_by_id: current_user.id,
        value: params[:value],
        note: params[:note]
      }, unique_by: [:option_id, :created_by_id])[0]['id']
      approval = Approval.find(approval_id)
      render json: approval
    end
  end
end
