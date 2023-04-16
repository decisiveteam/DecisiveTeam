class ApplicationController < ActionController::Base
  before_action :current_team
  def current_team
    return @current_team if defined?(@current_team)
    if current_user
      @current_team = Team.accessible_by(current_user).find_by(id: params[:team_id])
    else
      @current_team = nil
    end
  end
end
