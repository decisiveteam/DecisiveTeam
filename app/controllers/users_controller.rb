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
    @decision_participants = @showing_user.decision_participants.includes(:decision).order(created_at: :desc)
    @commitment_participants = @showing_user.commitment_participants.includes(:commitment).order(created_at: :desc)
  end

  def settings
    tu = current_tenant.tenant_users.find_by(handle: params[:handle])
    return render '404' if tu.nil?
    return render plain: '403 Unauthorized' unless tu.user == current_user
    @current_user.tenant_user = tu
  end

  def scratchpad
    tu = current_tenant.tenant_users.find_by(handle: params[:handle])
    return render '404' if tu.nil?
    return render plain: '403 Unauthorized' unless tu.user == current_user
    if params[:text].present?
      tu.settings['scratchpad']['text'] = params[:text]
      tu.save!
      render json: { success: true }
    else
      render status: 400, json: { error: 'Text is required' }
    end
  end

  def append_to_scratchpad
    tu = current_tenant.tenant_users.find_by(handle: params[:handle])
    return render '404' if tu.nil?
    return render plain: '403 Unauthorized' unless tu.user == current_user
    if params[:text].present?
      tu.settings['scratchpad']['text'] += "\n" + params[:text]
      tu.save!
      render json: { text: tu.settings['scratchpad']['text'] }
    else
      render status: 400, json: { error: 'Text is required' }
    end
  end

  def impersonate
    tu = current_tenant.tenant_users.find_by(handle: params[:handle])
    return render '404' if tu.nil?
    return render plain: '403 Unauthorized' unless current_user.can_impersonate?(tu.user)
    session[:impersonating] = tu.user.id
    redirect_to root_path
  end

  def stop_impersonating
    clear_impersonations_and_representations!
    redirect_to current_parent_user.path
  end

end