class ApplicationController < ActionController::Base

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
    elsif params[:decision_participant_id].present?
      @current_decision_participant = current_decision.participants.find_by(id: params[:decision_participant_id])
    elsif params[:participant_id].present?
      @current_decision_participant = current_decision.participants.find_by(id: params[:participant_id])
    elsif current_decision
      participant_uid = cookies[:decision_participant_uid] || SecureRandom.hex(16)
      cookies[:decision_participant_uid] = {
        value: participant_uid,
        expires: 30.days.from_now,
        httponly: true,
      }
      @current_decision_participant = DecisionParticipantManager.new(
        decision: current_decision,
        name: participant_uid,
      ).find_or_create_participant
    else
      @current_decision_participant = nil
    end
  end

  def current_approvals
    return @current_approvals if defined?(@current_approvals)
    if current_decision_participant
      @current_approvals = current_decision_participant.approvals
    else
      @current_approvals = nil
    end
  end
end
