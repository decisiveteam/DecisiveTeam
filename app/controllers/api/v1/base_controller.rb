class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :api_token_present?
  before_action :api_authorize!, if: :api_token_present?
  before_action :validate_can_write, if: :is_write_request?

  # Read actions are allowed by default
  def index
    render json: current_scope
  end

  def show
    render json: current_resource
  end

  # Write actions are not allowed by default
  def create
    render_404
  end

  def update
    render_404
  end
  
  def destroy
    render_404
  end
  
  private

  def render_404
    render json: { error: 'Not found' }, status: 404
  end

  def api_token_present?
    request.headers['Authorization'].present?
  end

  def api_authorize!
    return render json: { error: 'API not enabled' }, status: 403 unless ENV['API_TOKEN'].present?
    prefix, api_token = request.headers['Authorization'].split(' ')
    if prefix == 'Bearer' && api_token == ENV['API_TOKEN'] # TODO - Implement API tokens system
      true
    else
      render json: { error: 'Unauthorized' }, status: 401
    end
  end

  def is_write_request?
    ['POST', 'PUT', 'PATCH', 'DELETE'].include?(request.method)
  end

  def validate_can_write
    if current_decision && current_resource_model != Decision # is Option, Approval, or DecisionParticipant
      if current_decision.closed?
        render json: { error: 'Decision is closed' }, status: 403
      elsif current_decision.auth_required? && (!current_decision_participant || !current_decision_participant.authenticated?)
        render json: { error: 'Decision requires authentication' }, status: 403
      end
    end
  end

  def current_resource_model
    self.class.name.sub('Api::V1::', '').sub('Controller', '').singularize.constantize
  end

  def current_resource
    return @current_resource if defined?(@current_resource)  
    @current_resource = if current_resource_model == Decision
      current_decision
    else
      current_scope.find_by(id: params[:id])
    end
  end

  def current_scope
    current_resource_model.where(decision: current_decision)
  end

  def current_option
    return @current_option if defined?(@current_option)
    if current_resource_model == Option
      @current_option = current_resource
    elsif params[:option_id].present?
      o = Option.where(decision: current_decision)
      @current_option = o.find_by(id: params[:option_id])
    else
      @current_option = nil
    end
    @current_option
  end
end
