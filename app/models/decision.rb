class Decision < ApplicationRecord
  include Tracked
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :team

  has_many :options

  after_save :update_references

  def self.reference_pattern
    %r{/teams/(?<team_id>[0-9a-zA-Z]+)/decisions/(?<decision_id>[0-9a-zA-Z]+)}
  end

  def results
    DecisionResult.where(decision_id: self.id)
  end

  def path
    "/teams/#{self.team_id}/decisions/#{self.id}"
  end

  def number
    # TODO Add this as a generated column
    Decision.where(team: self.team).where('created_at < ?', self.created_at).count + 1
  end

  def reference_tag
    "T#{team_id}D#{number}"
  end

  def referenced_by
    # TODO Check if current_user can access both sides of references
    Decision.where(id: Reference.where(
      referenced: self,
      referencer_type: 'Decision'
    ).pluck(:referencer_id))
  end

  def reference_count
    referenced_by.count
  end

  def extract_references
    matches = self.context.scan(self.class.reference_pattern)
    matches.map do |team_id, decision_id|
      { team_id: team_id, decision_id: decision_id }
    end
  end

  def update_references
    extract_references.each do |ref|
      referenced_decision = Decision.accessible_by(created_by).where({
        team_id: ref[:team_id], id: ref[:decision_id]
      }).first
      if referenced_decision
        attrs = {
          referencer_team_id: self.team_id,
          referencer_decision_id: self.id,
          referencer: self,
          referencer_attribute: 'context', # TODO Make this dynamic
          referenced_team_id: referenced_decision.team_id,
          referenced_decision_id: referenced_decision.id,
          referenced: referenced_decision,
          created_by: self.created_by
        }
        existing_ref = Reference.where(attrs).first
        Reference.create!(attrs) unless existing_ref
      end
    end
  end
end
