class Decision < ApplicationRecord
  include Tracked
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :team
  has_many :options, dependent: :destroy
  has_many :approvals
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings
  validates :question, presence: true
  validates :status, inclusion: { in: %w(open draft finalized) }, allow_nil: true

  after_save :update_tags

  def is_finalized?
    status == 'finalized'
  end

  def finalize!
    self.status = 'finalized'
    save!
  end

  def results
    DecisionResult.where(decision_id: self.id)
  end

  def voter_count
    approvals.distinct.count(:created_by_id)
  end

  def path
    "/teams/#{self.team_id}/decisions/#{self.id}"
  end

  def reference_tag
    "#{id}"
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
      tags = Tag.extract_tags_from_string(val)
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
