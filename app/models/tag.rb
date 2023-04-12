class Tag < ApplicationRecord
  belongs_to :team
  has_many :taggings
  has_many :taggables, through: :taggings

  def self.pattern
    /#(\w+)/ # Simple hashtag pattern
  end

  def decisions
    Decision.where(
      team_id: self.team_id,
      id: Tagging.where(
        taggable_type: 'Decision',
        tag: self
      ).pluck(:taggable_id)
    )
  end
end
