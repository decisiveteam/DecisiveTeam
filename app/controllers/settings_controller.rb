class SettingsController < ApplicationController
  def index
    # TODO: Make this more secure. Only generate tokens on demand.
    # Allow users to revoke tokens.
    @api_token = current_user.create_api_token
  end

  def token
    if current_user
      token = current_user.create_api_token(params)
      render json: token
    end
  end
end