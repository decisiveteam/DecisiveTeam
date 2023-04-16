class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :doorkeeper_token_present?
  before_action :doorkeeper_authorize!, if: :doorkeeper_token_present?
  before_action :authenticate_user!, unless: :doorkeeper_token_present?

  def index
    render json: current_scope
  end

  def show
    render json: current_resource
  end

  private

  def doorkeeper_token_present?
    doorkeeper_token.present?
  end

  def current_user
    return @current_user if defined?(@current_user)
    if doorkeeper_token_present?
      @current_user = User.find(doorkeeper_token.resource_owner_id)
    else
      @current_user = super
    end
  end

  def current_team
    return @current_team if defined?(@current_team)
    @current_team = Team.accessible_by(current_user).find_by(id: params[:team_id])
  end

  def current_resource_model
    self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize
  end

  def current_scope
    # TODO Add OAuth token scopes, in addition to current_user accessibility
    return @current_scope if defined?(@current_scope)
    @current_scope = current_resource_model.accessible_by(current_user)
    if params[:team_id].present? && current_resource_model.has_attribute?(:team_id)
      @current_scope = @current_scope.where(team_id: params[:team_id])
    end
    if params[:decision_id].present? && current_resource_model.has_attribute?(:decision_id)
      @current_scope = @current_scope.where(decision_id: params[:decision_id])
    end
    if params[:option_id].present? && current_resource_model.has_attribute?(:option_id)
      @current_scope = @current_scope.where(option_id: params[:option_id])
    end
    @current_scope
  end

  def current_resource
    @current_resource ||= current_scope.find(params[:id])
  end

  def current_decision
    return @current_decision if defined?(@current_decision)
    if params[:decision_id].present?
      d = Decision.accessible_by(current_user)
      d = d.where(team: current_team) unless current_team.nil?
      @current_decision = d.find_by(id: params[:decision_id])
    else
      @current_decision = nil
    end
    @current_decision
  end

  def current_option
    return @current_option if defined?(@current_option)
    if params[:option_id].present?
      o = Option.accessible_by(current_user)
      o = o.where(team: current_team) unless current_team.nil?
      o = o.where(decision: current_decision) unless current_decision.nil?
      @current_option = o.find_by(id: params[:option_id])
    else
      @current_option = nil
    end
    @current_option
  end
end
