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

  def generate_invite_code(created_by:, expires_at:, max_uses:)
    TeamInvite.create!(
      team: self,
      created_by: created_by,
      expires_at: expires_at || 1.month.from_now,
      max_uses: max_uses || 10
    )
  end
end
