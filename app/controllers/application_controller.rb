class ApplicationController < ActionController::Base
  before_action :check_auth_subdomain, :current_app, :current_tenant, :current_studio,
                :current_path, :current_user, :current_resource

  def check_auth_subdomain
    if request.subdomain == auth_subdomain && controller_name != 'sessions'
      redirect_to '/login'
    end
  end

  def current_app
    # TODO Remove this method.
    # This method should be overridden in the app-specific controllers.
    return @current_app if defined?(@current_app)
    @current_app = ENV['APPS_ENABLED'].split(',')[0]
    @current_app_title = @current_app.titleize + ' Team'
    @current_app_description = case @current_app
    when 'decisive'
      'fast group decision-making'
    when 'coordinated'
      'fast group coordination'
    else
      raise "Unknown app: #{@current_app}"
    end
    @current_app
  end

  def current_tenant
    return @current_tenant if defined?(@current_tenant)
    current_studio
    @current_tenant ||= @current_studio.tenant
  end

  def current_studio
    return @current_studio if defined?(@current_studio)
    # begin
      # Studio.scope_thread_to_studio sets the current studio and tenant based on the subdomain and handle
      # and raises an error if the subdomain or handle is not found.
      # Default scope is configured in ApplicationRecord to scope all queries to
      # Tenant.current_tenant_id and Studio.current_studio_id
      # and automatically set tenant_id and studio_id on any new records.
      @current_studio = Studio.scope_thread_to_studio(
        subdomain: request.subdomain,
        handle: params[:studio_handle]
      )
      @current_tenant = @current_studio.tenant
      # Set these associations to avoid unnecessary reloading.
      @current_studio.tenant = @current_tenant
      @current_tenant.main_studio = @current_studio if @current_tenant.main_studio_id == @current_studio.id
    # rescue
    #   raise ActionController::RoutingError.new('Not Found')
    # end
    @current_studio
  end

  def current_path
    @current_path ||= request.path
  end

  def api_token_present?
    request.headers['Authorization'].present?
  end

  def current_token
    return @current_token if defined?(@current_token)
    return @current_token = nil unless api_token_present?
    prefix, token_string = request.headers['Authorization'].split(' ')
    @current_token = ApiToken.find_by(token: token_string, deleted_at: nil, tenant_id: current_tenant.id)
    return nil unless @current_token
    if prefix == 'Bearer' && @current_token&.active?
      @current_token.token_used!
    elsif prefix == 'Bearer' && @current_token&.expired? && !@current_token.deleted?
      render json: { error: 'Token expired' }, status: 401
    else
      render json: { error: 'Unauthorized' }, status: 401
    end
    @current_token
  end

  def api_authorize!
    api_enabled = true # TODO add to .env
    return render json: { error: 'API not enabled' }, status: 403 unless api_enabled
    return render json: { error: 'API only supports JSON or Markdown formats' }, status: 401 unless json_or_markdown_request?
    current_token || render(json: { error: 'Unauthorized' }, status: 401)
  end

  def json_or_markdown_request?
    # API tokens can only access JSON and Markdown endpoints.
    request.headers['Accept'] == 'application/json' ||
    request.headers['Accept'] == 'text/markdown' ||
    request.headers['Content-Type'] == 'application/json' ||
    request.headers['Content-Type'] == 'text/markdown' ||
    request.path.starts_with?('/api/') # Allow all API endpoints
  end

  def current_user
    return @current_user if defined?(@current_user)
    if api_token_present?
      api_authorize!
      return @current_user = @current_token&.user
    end
    if session[:impersonating].present?
      user = User.find_by(id: session[:impersonating])
      parent_user = User.find_by(id: session[:user_id])
      if user && parent_user&.can_impersonate?(user)
        @current_user = user
        @current_parent_user = parent_user
      end
    end
    if session[:user_id].present?
      @current_user ||= User.find_by(id: session[:user_id])
      if @current_user
        tu = current_tenant.tenant_users.find_by(user: @current_user)
        if tu.nil?
          # Sessions controller should have already handled this case.
          raise 'User is not a member of this tenant' if current_tenant.require_login?
        else
          # This assignment prevents unnecessary reloading.
          @current_user.tenant_user = tu
        end
      end
      if @current_user
        su = current_studio.studio_users.find_by(user: @current_user)
        if su.nil?
          if current_studio == current_tenant.main_studio
            current_studio.add_user!(@current_user) unless controller_name == 'sessions'
          else
            # If this user has an invite to this studio, they will see the option to accept on the studio's join page.
            # Otherwise, they will see the studio's default join page, which may or may not allow them to join.
            path = "#{current_studio.path}/join"
            redirect_to path unless request.path == path
          end
        else
          # TODO Add last_seen_at to StudioUser instead of touch
          su.touch if controller_name != 'sessions'
          @current_user.studio_user = su
        end
      end
    elsif @current_tenant.require_login? && controller_name != 'sessions'
      if current_resource
        path = current_resource.path
        query_string = "?redirect_to_resource=#{path}"
      elsif params[:code] && controller_name == 'studios'
        # Studio invite code
        query_string = "?code=#{params[:code]}"
      end
      redirect_to '/login' + (query_string || '')
    else
      @current_user = nil
    end
    @current_user
  end

  def current_parent_user
    @current_parent_user
  end

  def current_resource_model
    return @current_resource_model if defined?(@current_resource_model)
    if controller_name == 'home' || controller_name == 'sessions'
      @current_resource_model = nil
    else
      @current_resource_model = controller_name.classify.constantize
    end
    @current_resource_model
  end

  def current_resource
    return @current_resource if defined?(@current_resource)
    return nil unless current_resource_model
    case current_resource_model.name
    when 'Decision'
      @current_resource = current_decision
    when 'Commitment'
      @current_resource = current_commitment
    when 'Note'
      @current_resource = current_note
    else
      @current_resource = nil
    end
    @current_resource
  end


  def current_decision
    return @current_decision if defined?(@current_decision)
    if current_resource_model == Decision
      decision_id = params[:id] || params[:decision_id]
    else
      decision_id = params[:decision_id]
    end
    column_name = decision_id.to_s.length == 8 ? :truncated_id : :id
    @current_decision = Decision.find_by(column_name => decision_id)
  end

  def current_decision_participant
    return @current_decision_participant if defined?(@current_decision_participant)
    if current_resource_model == DecisionParticipant
      @current_decision_participant = current_resource
    # elsif params[:decision_participant_id].present?
    #   @current_decision_participant = current_decision.participants.find_by(id: params[:decision_participant_id])
    # elsif params[:participant_id].present?
    #   @current_decision_participant = current_decision.participants.find_by(id: params[:participant_id])
    elsif current_decision
      @current_decision_participant = DecisionParticipantManager.new(
        decision: current_decision,
        user: current_user,
        participant_uid: cookies[:decision_participant_uid],
      ).find_or_create_participant
      unless current_user
        # Cookie is only needed if user is not logged in.
        cookies[:decision_participant_uid] = {
          value: @current_decision_participant.participant_uid,
          expires: 30.days.from_now,
          httponly: true,
        }
      end
    else
      @current_decision_participant = nil
    end
    @current_decision_participant
  end

  def current_approvals
    return @current_approvals if defined?(@current_approvals)
    if current_decision_participant
      @current_approvals = current_decision_participant.approvals
    else
      @current_approvals = nil
    end
  end

  def current_commitment
    return @current_commitment if defined?(@current_commitment)
    if current_resource_model == Commitment
      commitment_id = params[:id] || params[:commitment_id]
    else
      commitment_id = params[:commitment_id]
    end
    column_name = commitment_id.to_s.length == 8 ? :truncated_id : :id
    @current_commitment = Commitment.find_by(column_name => commitment_id)
  end

  def current_commitment_participant
    return @current_commitment_participant if defined?(@current_commitment_participant)
    if current_resource_model == CommitmentParticipant
      @current_commitment_participant = current_resource
    elsif current_commitment
      @current_commitment_participant = CommitmentParticipantManager.new(
        commitment: current_commitment,
        user: current_user,
        participant_uid: cookies[:commitment_participant_uid],
      ).find_or_create_participant
      unless current_user
        # Cookie is only needed if user is not logged in.
        cookies[:commitment_participant_uid] = {
          value: @current_commitment_participant.participant_uid,
          expires: 30.days.from_now,
          httponly: true,
        }
      end
    else
      @current_commitment_participant = nil
    end
    @current_commitment_participant
  end

  def current_note
    return @current_note if defined?(@current_note)
    if current_resource_model == Note
      note_id = params[:id] || params[:note_id]
    else
      note_id = params[:note_id]
    end
    column_name = note_id.to_s.length == 8 ? :truncated_id : :id
    @current_note = Note.find_by(column_name => note_id)
  end

  def duration_param
    duration = model_params[:duration].to_i
    duration_unit = model_params[:duration_unit] || 'hour(s)'
    case duration_unit
    when 'minute(s)'
      duration.minutes
    when 'hour(s)'
      duration.hours
    when 'day(s)'
      duration.days
    when 'week(s)'
      duration.weeks
    when 'month(s)'
      duration.months
    when 'year(s)'
      duration.years
    else
      raise "Unknown duration_unit: #{duration_unit}"
    end
  end

  def model_params
    params[current_resource_model.name.underscore.to_sym] || params
  end

  def reset_session
    clear_participant_uid_cookie
    super
  end

  def clear_participant_uid_cookie
    cookies.delete(:decision_participant_uid)
  end

  def encryptor
    @encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.secret_key_base[0..31])
  end

  def encrypt(data)
    encryptor.encrypt_and_sign(data.to_json)
  end

  def decrypt(data)
    JSON.parse(encryptor.decrypt_and_verify(data))
  end

  def auth_subdomain
    ENV['AUTH_SUBDOMAIN']
  end

  def auth_domain_login_url
    "https://#{auth_subdomain}.#{ENV['HOSTNAME']}/login"
  end

  def pin
    @pinnable = current_resource
    return render '404', status: 404 unless @pinnable
    if params[:pinned] == true
      @pinnable.pin!(tenant: @current_tenant, studio: @current_studio, user: @current_user)
    elsif params[:pinned] == false
      @pinnable.unpin!(tenant: @current_tenant, studio: @current_studio, user: @current_user)
    else
      raise 'pinned param required. must be boolean value'
    end
    set_pin_vars
    render json: {
      pinned: @is_pinned,
      click_title: @pin_click_title,
    }
  end

  def set_pin_vars
    @pinnable = current_resource
    pin_destination = current_studio == current_tenant.main_studio ? 'your profile' : 'the studio homepage'
    @is_pinned = current_resource.is_pinned?(tenant: @current_tenant, studio: @current_studio, user: @current_user)
    @pin_click_title = 'Click to ' + (@is_pinned ? 'unpin from ' : 'pin to ') + pin_destination
  end
end
