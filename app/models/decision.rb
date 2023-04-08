class Decision < ApplicationRecord
  include Tracked
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :team

  has_many :options

  def results
    DecisionResult.where(decision_id: self.id)
  end

  def path
    "/teams/#{self.team_id}/decisions/#{self.id}"
  end

  def reference_count
    0 # TODO
  end
end
