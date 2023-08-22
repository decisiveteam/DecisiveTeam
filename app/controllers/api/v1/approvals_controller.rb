module Api::V1
  class ApprovalsController < BaseController
    def create
      approval = Approval.find_by(associations) || Approval.new(associations)
      approval.value = params[:value]
      approval.stars = params[:stars]
      approval.save!
      render json: approval
    end

    def update
      approval = Approval.where(associations).find_by(id: params[:id])
      return render json: { error: 'Approval not found' }, status: 404 unless approval
      approval.value = params[:value] if params[:value].present?
      approval.stars = params[:stars] if params[:stars].present?
      approval.save!
      render json: approval
    end

    private

    def associations
      @associations ||= {
        decision: current_decision,
        option: current_option,
        decision_participant: current_decision_participant,
      }
    end

    def current_scope
      return @current_scope if defined?(@current_scope)
      @current_scope = super
      @current_scope = @current_scope.where(option: current_option) if current_option
      @current_scope = @current_scope.where(decision_participant: current_decision_participant) if current_decision_participant
      @current_scope
    end

  end
end
