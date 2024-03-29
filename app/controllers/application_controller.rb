class ApplicationController < ActionController::Base
  before_action :current_user

  def current_user
    return @current_user if defined?(@current_user)
    if session[:user_id].present?
      @current_user = User.find_by(id: session[:user_id])
    else
      @current_user = nil
    end
  end

  def current_resource_model
    self.class.name.sub('Controller', '').singularize.constantize
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
end
