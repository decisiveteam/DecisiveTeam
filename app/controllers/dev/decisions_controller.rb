module Dev
  class DecisionsController < ApplicationController
    before_action :assert_env_is_dev

    def assert_env_is_dev
      raise 'Not in dev environment' unless Rails.env.development?
    end
    
    def create
      if params[:title]
        option = Option.create!(
          team_id: 1,
          decision_id: 1,
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
        # decision = Decision.create!(
        #   team_id: 1,
        #   decision_log_id: 1,
        #   created_by: current_user,
        #   context: params[:context],
        #   question: params[:question],
        #   status: params[:status],
        #   deadline: params[:deadline],
        #   external_ids: params[:external_ids],
        # )
        # render json: decision
      end
    end
  end
end
