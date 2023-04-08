class Team < ApplicationRecord
  has_many :team_members
  has_many :users, through: :team_members
  has_many :decisions
  has_many :options
  has_many :approvals

  def self.accessible_by(user)
    self.where(id: user.teams)
  end

  def path
    "/teams/#{self.id}"
  end
end
