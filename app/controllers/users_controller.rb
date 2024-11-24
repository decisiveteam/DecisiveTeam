class UsersController < ApplicationController
  def index
    @users = current_tenant.tenant_users
  end

  def show
    tu = current_tenant.tenant_users.find_by(handle: params[:handle])
    return render '404' if tu.nil?
    @showing_user = tu.user
    @showing_user.tenant_user = tu
    @pinned_items = @showing_user.pinned_items
    @confirmed_read_note_events = @showing_user.confirmed_read_note_events
  end
end