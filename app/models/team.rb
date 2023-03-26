class Team < ApplicationRecord
  has_many :team_members
  has_many :users, through: :team_members
  has_many :decision_logs
  has_many :decisions
  has_many :options
  has_many :approvals
end
