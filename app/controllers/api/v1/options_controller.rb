module Api::V1
  class OptionsController < BaseController    
    def create
      if current_decision.can_add_options?(current_decision_participant)
        option = Option.create!(
          decision: current_decision,
          decision_participant: current_decision_participant,
          title: params[:title],
          description: params[:description],
          other_attributes: {} # TODO
        )
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
        # option.other_attributes # TODO
        option.save!
        render json: option
      else
        render json: { error: 'Cannot update options' }, status: 403
      end
    end
    
    def destroy
      # TODO Check for approvals first
      option = current_resource
      option.destroy!
      render json: option
    end
  end
end