class HomeController < ApplicationController
  before_action :set_current_resources

  def index
    @partial = 'index'
  end

  def team
    @partial = 'team'
    render 'index'
  end

  def decision_log
    @partial = 'decision_log'
    render 'index'
  end

  def decision
    @partial = 'decision'
    render 'index'
  end

  def set_current_resources
    @current_user = current_user
    @current_team = @current_user.teams.find(params[:team_id]) if params[:team_id]
    @current_decision_log = @current_team.decision_logs.find(params[:decision_log_id]) if params[:decision_log_id]
    @current_decision = Decision.accessible_by(current_user).find(params[:decision_id]) if params[:decision_id]
  end
end
