module Api::V1
  class ApprovalsController < BaseController
    def create
      approval = Approval.create!(
        team: current_team,
        decision: current_decision,
        option: current_option,
        created_by: current_user,
        value: params[:value],
        note: params[:note]
      )
      render json: approval
    end
  end
end
