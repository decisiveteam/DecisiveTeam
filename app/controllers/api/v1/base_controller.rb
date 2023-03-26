class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  before_action -> { doorkeeper_authorize! :read }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write }, only: [:create, :update, :destroy]

  def current_user
    @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_team
    return @current_team if defined?(@current_team)
    @current_team = Team.accessible_by(current_user).find_by(id: params[:team_id])
  end

  def current_resource_model
    self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize
  end

  def current_scope
    @current_scope ||= current_resource_model.accessible_by(current_user)
  end

  def current_decision_log
    return @current_decision_log if defined?(@current_decision_log)
    @current_decision_log = DecisionLog.accessible_by(current_user)
    @current_decision_log = @current_decision_log.where(team_id: current_team.id) unless current_team.nil?
    @current_decision_log = @current_decision_log.find_by(id: params[:decision_log_id]) if params[:decision_log_id].present?
    @current_decision_log
  end

  def current_decision
    Decision.accessible_by(current_user).find_by(
      id: params[:decision_id],
      team_id: current_team.id,
      decision_log_id: current_decision_log.id
    ) if params[:decision_id].present?
  end

end
