module Api::V1
  class OptionsController < BaseController
    def create
      if current_decision.can_add_options?(current_decision_participant)
        ActiveRecord::Base.transaction do
          option = Option.create!(
            decision: current_decision,
            decision_participant: current_decision_participant,
            title: params[:title],
            description: params[:description],
          )
          if current_representation_session
            current_representation_session.record_activity!(
              request: request,
              semantic_event: {
                timestamp: Time.current,
                event_type: 'add_option',
                studio_id: current_studio.id,
                main_resource: {
                  type: 'Decision',
                  id: current_decision.id,
                  truncated_id: current_decision.truncated_id,
                },
                sub_resources: [
                  {
                    type: 'Option',
                    id: option.id,
                  },
                ],
              }
            )
          end
        end
        render json: option
      else
        render json: { error: 'Cannot add options' }, status: 403
      end
    end

    def update
      if current_decision.can_update_options?(current_decision_participant)
          # TODO Abstract this into base controller and base model
        option = current_resource
        option.title = params[:title] if params[:title].present?
        option.description = params[:description] if params[:description].present?
        option.save!
        # TODO how to record this when in representation session?
        render json: option
      else
        render json: { error: 'Cannot update options' }, status: 403
      end
    end

    def destroy
      if current_decision.can_delete_options?(current_decision_participant)
        # TODO Check for approvals first
        option = current_resource
        option.destroy!
        # TODO how to record this when in representation session?
        render json: option
      else
        render json: { error: 'Cannot delete options' }, status: 403
      end
    end
  end
end