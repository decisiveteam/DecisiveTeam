class HomeController < ApplicationController
  before_action :set_current_resources

  def index
    if current_user
      @teams = Team.accessible_by(current_user)
    end
  end

  def set_current_resources
    @current_user = current_user
    @current_team = @current_user.teams.find(params[:team_id]) if params[:team_id]
    @current_decision = Decision.accessible_by(current_user).find(params[:decision_id]) if params[:decision_id]
  end
end
