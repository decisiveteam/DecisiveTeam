module Api::V1
  class OptionsController < BaseController    
    def create
      option = Option.create!(
        team: current_team,
        decision: current_decision,
        decision_participant: current_decision_participant,
        title: params[:title],
        description: params[:description],
        other_attributes: {} # TODO
      )
      render json: option
    end

    def update
      # TODO Abstract this into base controller and base model
      option = current_resource
      option.title = params[:title] if params[:title].present?
      option.description = params[:description] if params[:description].present?
      # option.other_attributes # TODO
      option.save!
      render json: option
    end
    
    def destroy
      # TODO Check for approvals first
      option = current_resource
      option.destroy!
      render json: option
    end
  end
end