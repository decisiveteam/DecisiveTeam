class ApplicationController < ActionController::Base
  before_action :check_auth_subdomain, :current_app, :current_tenant, :current_studio,
                :current_path, :current_user, :current_resource, :current_representation_session

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
    api_enabled = current_tenant.api_enabled? && current_studio.api_enabled?
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
      # How do we handle representation through the API?
      return @current_user = @current_token&.user
    end
    @current_person_user = User.find_by(id: session[:user_id], user_type: 'person') if session[:user_id].present?
    @current_simulated_user = User.find_by(id: session[:simulated_user_id], user_type: 'simulated') if session[:simulated_user_id].present?
    @current_trustee_user = User.find_by(id: session[:trustee_user_id], user_type: 'trustee') if session[:trustee_user_id].present?
    if @current_simulated_user && @current_person_user&.can_impersonate?(@current_simulated_user)
      @current_user = @current_simulated_user
    elsif @current_simulated_user
      clear_impersonations_and_representations!
      @current_simulated_user = nil
      @current_user = @current_person_user
    else
      @current_user = @current_person_user
    end
    if @current_trustee_user && @current_user&.can_represent?(@current_trustee_user)
      @current_user = @current_trustee_user
    elsif @current_trustee_user
      clear_impersonations_and_representations!
      @current_trustee_user = nil
      @current_user = @current_person_user
    end
    @current_user ||= @current_person_user
    if @current_user
      validate_authenticated_access
    else
      validate_unauthenticated_access
    end
    @current_user
  end

  def validate_authenticated_access
    tu = current_tenant.tenant_users.find_by(user: @current_user)
    if tu.nil?
      # Sessions controller should have already handled this case.
      if @current_tenant.require_login? && controller_name != 'sessions'
        render status: 403, layout: 'application', template: 'sessions/403_to_logout'
      end
    else
      # This assignment prevents unnecessary reloading.
      @current_user.tenant_user = tu
    end
    su = current_studio.studio_users.find_by(user: @current_user)
    if su.nil?
      if current_studio == current_tenant.main_studio
        if controller_name == 'sessions' || @current_user.trustee?
          # Do nothing
        else
          current_studio.add_user!(@current_user)
        end
      elsif current_user.trustee? && current_user.trustee_studio == current_studio
        # TODO - decide how to handle this case. Trustee is not a member of the studio, but is the trustee.
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

  def validate_unauthenticated_access
    return if @current_user || !@current_tenant.require_login? || controller_name == 'sessions'
    if current_resource
      path = current_resource.path
      query_string = "?redirect_to_resource=#{path}"
    elsif params[:code] && controller_name == 'studios'
      # Studio invite code
      query_string = "?code=#{params[:code]}"
    end
    redirect_to '/login' + (query_string || '')
  end

  def clear_impersonations_and_representations!
    session.delete(:simulated_user_id)
    session.delete(:representation_session_id)
    session.delete(:trustee_user_id)
    @current_user = @current_person_user
    @current_simulated_user = nil
    @current_representation_session&.end!
    @current_representation_session = nil
  end

  def current_person_user
    @current_person_user
  end

  def current_simulated_user
    @current_simulated_user
  end

  def current_representation_session
    return @current_representation_session if defined?(@current_representation_session)
    if session[:representation_session_id].present?
      @current_representation_session = RepresentationSession.unscoped.find_by(
        trustee_user: @current_user,
        # Person can be impersonating a simulated user who is representing the studio via a representation session, all simultaneously.
        representative_user: @current_simulated_user || @current_person_user,
        studio: @current_user.trustee_studio,
        id: session[:representation_session_id]
      )
      if @current_representation_session.nil?
        # TODO - not sure what to do here. What are the security concerns?
        clear_impersonations_and_representations!
        flash[:alert] = 'Representation session not found. Please try again.'
      elsif @current_representation_session.expired?
        clear_impersonations_and_representations!
        flash[:alert] = 'Representation session expired.'
      elsif !request.path.starts_with?('/representing') && !request.path.starts_with?('/s/')
        # Representation session should always be scoped to a studio or the /representing page.
        # The one edge case exception is when a person user is impersonating a simulated user and
        # is ending the impersonation before ending the representation session.
        # In this case, the representation session should be ended automatically.
        ending_impersonation = @current_simulated_user && request.path.ends_with?('/impersonate')
        if ending_impersonation
          # Allow request to proceed. UsersController#stop_impersonating will handle the end of the representation session.
        else
          redirect_to '/representing'
        end
      end
    end
    @current_representation_session ||= nil
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
    return @current_decision = nil unless decision_id
    @current_decision = Decision.find(decision_id)
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
    return @current_commitment = nil unless commitment_id
    @current_commitment = Commitment.find(commitment_id)
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
    return @current_note = nil unless note_id
    @current_note = Note.find(note_id)
  end

  def current_cycle
    return @current_cycle if defined?(@current_cycle)
    @current_cycle = Cycle.new_from_tempo(tenant: current_tenant, studio: current_studio)
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
