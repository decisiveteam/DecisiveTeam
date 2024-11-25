class ApplicationController < ActionController::Base
  before_action :check_auth_subdomain, :current_app, :current_tenant, :current_user, :current_resource

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
    begin
      # Tenant.scope_thread_to_tenant sets the current tenant based on the subdomain
      # and raises an error if the subdomain is not found.
      # Default scope is configured in ApplicationRecord to scope all queries to Tenant.current_tenant_id
      # and automatically set tenant_id on any new records.
      @current_tenant = Tenant.scope_thread_to_tenant(subdomain: request.subdomain)
    rescue
      raise ActionController::RoutingError.new('Not Found')
    end
    @breadcrumb_path ||= []
    @breadcrumb_path << @current_tenant.name
    @current_tenant
  end

  def current_user
    return @current_user if defined?(@current_user)
    if session[:user_id].present?
      @current_user = User.find_by(id: session[:user_id])
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
    elsif @current_tenant.require_login? && controller_name != 'sessions'
      if current_resource
        path = current_resource.path
        query_string = "?redirect_to_resource=#{path}"
      end
      redirect_to '/login' + (query_string || '')
    else
      @current_user = nil
    end
    @current_user
  end

  def authenticate_user!
    redirect_to root_path unless current_user
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
    else
      raise "Unknown duration_unit: #{duration_unit}"
    end
  end

  def model_params
    params[current_resource_model.name.underscore.to_sym]
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
end
