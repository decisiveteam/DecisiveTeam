module Api::V1
  class ApprovalsController < BaseController
    def create
      approval = Approval.find_by(associations) || Approval.new(associations)
      approval.value = params[:value]
      approval.stars = params[:stars]
      ActiveRecord::Base.transaction do
        approval.save!
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'vote',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Decision',
                id: current_decision.id,
                truncated_id: current_decision.truncated_id,
              },
              sub_resources: [
                {
                  type: 'Option',
                  id: current_option.id,
                },
                {
                  type: 'Approval',
                  id: approval.id,
                },
              ],
            }
          )
        end
      end
      render json: approval
    end

    def update
      approval = Approval.where(associations).find_by(id: params[:id])
      return render json: { error: 'Approval not found' }, status: 404 unless approval
      approval.value = params[:value] if params[:value].present?
      approval.stars = params[:stars] if params[:stars].present?
      ActiveRecord::Base.transaction do
        approval.save!
        if current_representation_session
          current_representation_session.record_activity!(
            request: request,
            semantic_event: {
              timestamp: Time.current,
              event_type: 'vote',
              studio_id: current_studio.id,
              main_resource: {
                type: 'Decision',
                id: current_decision.id,
                truncated_id: current_decision.truncated_id,
              },
              sub_resources: [
                {
                  type: 'Option',
                  id: current_option.id,
                },
                {
                  type: 'Approval',
                  id: approval.id,
                },
              ],
            }
          )
        end
      end
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
