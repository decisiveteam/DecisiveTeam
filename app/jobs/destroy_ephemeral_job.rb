class DestroyEphemeralJob < ApplicationJob
  queue_as :default

  def perform(decision_id)
    decision = Decision.find_by(id: decision_id)
    if decision
      destroyed = decision.destroy_ephemeral!
      if !destroyed && decision.status == 'ephemeral'
        decision.schedule_destroy_ephemeral
      end
    end
  end
end