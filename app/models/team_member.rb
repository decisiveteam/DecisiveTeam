class TeamMember < ApplicationRecord
  include Tracked
  belongs_to :team
  belongs_to :user
  belongs_to :team_invite, optional: true

  def is_user?
    !user_id.nil?
  end
end
