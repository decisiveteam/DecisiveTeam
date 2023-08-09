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
    @current_decision = Decision.find_by(id: decision_id)
  end

  def current_decision_participant
    return @current_decision_participant if defined?(@current_decision_participant)
    if current_decision
      @current_decision_participant = DecisionParticipantManager.new(
        decision: current_decision,
        # TODO - refactor this. This is a hack to allow admins to easily create participants and approvals.
        name: params[:participant_name],
      ).find_or_create_participant
    else
      @current_decision_participant = nil
    end
  end

  def current_approvals
    return @current_approvals if defined?(@current_approvals)
    if current_decision_participant
      @current_approvals = current_decision_participant.approvals.where(decision: current_decision)
    else
      @current_approvals = nil
    end
  end
end
