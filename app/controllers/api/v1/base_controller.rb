class Api::V1::BaseController < ApplicationController

  def index
    render json: current_scope
  end

  def show
    render json: current_resource
  end

  private

  def is_write_request?
    ['POST', 'PUT', 'PATCH', 'DELETE'].include?(request.method)
  end

  def current_resource_model
    self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize
  end

  def current_decision
    return @current_decision if defined?(@current_decision)
    if params[:decision_id].present?
      d = Decision
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
      o = Option
      o = o.where(decision: current_decision) unless current_decision.nil?
      @current_option = o.find_by(id: params[:option_id])
    else
      @current_option = nil
    end
    @current_option
  end
end
