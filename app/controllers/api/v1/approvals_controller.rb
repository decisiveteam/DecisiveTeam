module Api::V1
  class ApprovalsController < BaseController
    def create
      associations = {
        team: current_team,
        decision: current_decision,
        option: current_option,
        decision_participant: current_decision_participant,
      }
      approval = Approval.find_by(associations) || Approval.new(associations)
      approval.value = params[:value]
      approval.stars = params[:stars]
      approval.note = params[:note]
      approval.save!
      render json: approval
    end
  end
end
