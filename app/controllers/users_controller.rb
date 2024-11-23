class UsersController < ApplicationController
  def index
    @users = current_tenant.tenant_users
  end

  def show
    @showing_user = current_tenant.tenant_users.find_by(handle: params[:handle])
    return render '404' if @showing_user.nil?
    @pinned_items = @showing_user.pinned_items
  end
end