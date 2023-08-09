class HomeController < ApplicationController
  before_action :set_current_resources

  def index
  end

  def set_current_resources
    @current_decision = Decision.find(params[:decision_id]) if params[:decision_id]
  end
end
