class Decision < ApplicationRecord
  include Tracked
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :decision_log
  belongs_to :team

  def results
    DecisionResult.where(decision_id: self.id)
  end
end
