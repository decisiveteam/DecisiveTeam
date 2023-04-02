class Webhook < ApplicationRecord
  belongs_to :team
  belongs_to :decision_log, optional: true
  belongs_to :decision, optional: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'

  def self.queue_jobs_for(resource, event)
    # Assuming all resources are scoped to team
    s = self.where(team: resource.team)
    case resource.class
    when TeamMember
      # noop
    when DecisionLog
      s = s.where(decision_log: [resource, nil])
    when Decision
      s = s.where(decision_log: [resource.decision_log, nil], decision: [resource, nil])
    when Option, Approval
      s = s.where(decision_log: [resource.decision_log, nil], decision: [resource.decision, nil])
    end
    # TODO check event
    s.each do |wh|
      wh.queue_job(event)
    end
  end

  def queue_job(event)
    SendWebhookJob.perform_later(self.id, event)
  end
end
