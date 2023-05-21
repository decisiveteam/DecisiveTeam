class ApplicationController < ActionController::Base
  before_action :current_team

  def current_resource_model
    self.class.name.sub('Controller', '').singularize.constantize
  end

  def current_team
    return @current_team if defined?(@current_team)
    if current_user
      @current_team = Team.accessible_by(current_user).find_by(id: params[:team_id])
    else
      @current_team = nil
    end
  end

  def current_team_member
    return @current_team_member if defined?(@current_team_member)
    if current_team
      @current_team_member = current_team.team_members.find_by(user: current_user)
    else
      @current_team_member = nil
    end
  end

  def current_decision
    return @current_decision if defined?(@current_decision)
    if current_team
      # TODO implement non-team member participants
      if current_resource_model == Decision
        decision_id = params[:id] || params[:decision_id]
      else
        decision_id = params[:decision_id]
      end
      @current_decision = current_team.decisions.find_by(id: decision_id)
    else
      @current_decision = nil
    end
  end

  def current_decision_participant
    return @current_decision_participant if defined?(@current_decision_participant)
    if current_decision && current_user
      @current_decision_participant = DecisionParticipantManager.new(
        decision: current_decision,
        entity: current_user,
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
