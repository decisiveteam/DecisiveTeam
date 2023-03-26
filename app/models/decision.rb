class Decision < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :decision_log
  belongs_to :team

  def self.accessible_by(user)
    self.where(team: user.teams)
  end
end
