class TeamMember < ApplicationRecord
  include Tracked
  belongs_to :team
  belongs_to :user

  def is_user?
    !user_id.nil?
  end
end
