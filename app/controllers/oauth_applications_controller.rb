class OauthApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_oauth_application, only: [:edit, :update, :destroy]

  def index
    @oauth_applications = current_user.oauth_applications
  end

  def new
    @oauth_application = Doorkeeper::Application.new
  end

  def create
    @oauth_application = current_user.oauth_applications.build(oauth_application_params)

    if @oauth_application.save
      redirect_to oauth_applications_path, notice: 'OAuth application was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @oauth_application.update(oauth_application_params)
      redirect_to oauth_applications_path, notice: 'OAuth application was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @oauth_application.destroy
    redirect_to oauth_applications_path, notice: 'OAuth application was successfully deleted.'
  end

  private

  def set_oauth_application
    @oauth_application = current_user.oauth_applications.find(params[:id])
  end

  def oauth_application_params
    # params.require(:oauth_application).permit(:name, :redirect_uri, :scopes, :confidential)
    params.require(:doorkeeper_application).permit(:name, :redirect_uri, :scopes, :confidential)
  end
end
