class CloseDecisionJob < ApplicationJob
  queue_as :scheduled

  def perform(decision_id)
    decision = Decision.find_by(id: decision_id)
    decision.close_if_deadline_passed! if decision
  end
end