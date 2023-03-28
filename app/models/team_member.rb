class TeamMember < ApplicationRecord
  include Tracked
  belongs_to :team
  belongs_to :user
end
