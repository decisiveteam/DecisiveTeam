class Decision < ApplicationRecord
  include Tracked
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :team
  has_many :options
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  after_save :update_tags

  def results
    DecisionResult.where(decision_id: self.id)
  end

  def path
    "/teams/#{self.team_id}/decisions/#{self.id}"
  end

  def number
    # TODO Add this as a generated column
    Decision.where(team: self.team).where('created_at < ?', self.created_at).count + 1
  end

  def reference_tag
    "T#{team_id}D#{number}"
  end

  def referenced_by
    tag = Tag.find_by(team_id: self.team_id, name: self.reference_tag)
    if tag
      tag.decisions
    else
      Decision.none
    end
  end

  def reference_count
    referenced_by.count
  end

  def extract_tags
    all_tags = []
    self.other_attributes.map do |key, val|
      tags = val.scan(Tag.pattern).flatten
      unless tags.empty?
        all_tags << { key: key, tags: tags }
      end
    end
    all_tags
  end

  def update_tags
    self.taggings = extract_tags.map do |key_and_tags|
      key = key_and_tags[:key]
      tags = key_and_tags[:tags]
      tags.map do |tag|
        tag_record = Tag.find_or_create_by(name: tag, team_id: self.team_id)
        Tagging.find_or_create_by(
          tag: tag_record,
          taggable: self,
          key: key
        )
      end
    end.flatten
  end
end
