class ApiTokensController < ApplicationController
  before_action :set_user

  def new
    @token = @showing_user.api_tokens.new(user: @showing_user)
  end

  def create
    @token = @showing_user.api_tokens.new
    @token.name = token_params[:name]
    @token.scopes = ApiToken.read_scopes
    @token.scopes += ApiToken.write_scopes if token_params[:read_write] == 'write'
    @token.expires_at = Time.current + [duration_param, 1.year].min
    @token.save!
    redirect_to @token.path
  end

  def show
    @token = @showing_user.api_tokens.find_by(id: params[:id])
    return render '404' if @token.nil?
  end

  def destroy
    @token = @showing_user.api_tokens.find_by(id: params[:id])
    return render '404' if @token.nil?
    @token.delete!
    redirect_to "#{@showing_user.path}/settings"
  end

  private

  def token_params
    # duration_param is defined in the ApplicationController
    params.require(:api_token).permit(:name, :read_write).merge(user: @showing_user)
  end

  def set_user
    tu = current_tenant.tenant_users.find_by(handle: params[:user_handle])
    tu ||= current_tenant.tenant_users.find_by(user_id: params[:user_handle])
    return render '404' if tu.nil?
    return render plain: '403 Unauthorized' unless tu.user == current_user
    @showing_user = tu.user
    @showing_user.tenant_user = tu
  end

end