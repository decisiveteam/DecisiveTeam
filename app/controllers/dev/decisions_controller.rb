module Dev
  class DecisionsController < ApplicationController
    before_action :assert_env_is_dev

    def assert_env_is_dev
      raise 'Not in dev environment' unless Rails.env.development?
    end
    
    def create
      if params[:title]
        decision = Decision.accessible_by(current_user).find(params[:decision_id])
        option = Option.create!(
          team_id: decision.team_id,
          decision_id: decision.id,
          created_by: current_user,
          title: params[:title],
        )
        render json: option
      elsif params.has_key?(:value) && params[:option_id]
        approval = Approval.where(option_id: params[:option_id], created_by: current_user).first
        approval ||= Approval.new(
          team_id: 1,
          decision_id: 1,
          option_id: params[:option_id],
          created_by: current_user,
          value: params[:value],
        )
        approval.value = params[:value]
        approval.save!
        render json: approval
      else
        raise "Invalid Request"
      end
    end
  end
end
