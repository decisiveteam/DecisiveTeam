class Tag < ApplicationRecord
  belongs_to :team
  has_many :taggings
  has_many :taggables, through: :taggings

  validate :validate_name_format

  # after_save :update_description_tags

  def self.pattern
    /#(\w+)/ # Simple name pattern
  end

  def self.is_decision_tag?(string)
    # All digits means decision ID
    string.match?(/\A\d+\z/)
  end

  def self.extract_tags_from_string(string)
    string.scan(self.pattern).flatten
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

  def path
    "/teams/#{team_id}/tags/#{name}"
  end

  private

  def validate_name_format
    name_pattern = /\A\w+\z/

    unless name_pattern.match?(name)
      errors.add(:name, 'is not a valid name format')
    end
  end
end
