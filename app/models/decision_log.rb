class DecisionLog < ApplicationRecord
  belongs_to :team

  def self.accessible_by(user)
    self.where(team: user.teams)
  end
end
