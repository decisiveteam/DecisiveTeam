class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  def current_team
    Team.first # FIXME: this should map to the current user's team via team membership
  end

  def current_resource_model
    self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize
  end

  def current_scope
    current_resource_model.where(team_id: current_team.id)
  end

  def current_decision_log
    if params[:decision_log_id].present?
      DecisionLog.find_by(
        id: params[:decision_log_id],
        team_id: current_team.id
      )
    else
      nil
    end
  end

  def current_team_member
    current_user # FIXME
  end

  def current_decision
    if params[:decision_id].present?
      Decision.find_by(
        id: params[:decision_id],
        team_id: current_team.id,
        decision_log_id: current_decision_log.id
      )
    else
      nil
    end
  end

end
