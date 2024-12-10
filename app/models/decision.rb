class Decision < ApplicationRecord
  include Tracked
  include Linkable
  include Pinnable
  include HasTruncatedId
  include Attachable
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by_id'
  has_many :decision_participants, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :approvals # dependent: :destroy through options

  validates :question, presence: true

  def self.api_json
    map { |decision| decision.api_json }
  end

  def api_json(include: [])
    response = {
      id: id,
      truncated_id: truncated_id,
      question: question,
      description: description,
      options_open: options_open,
      deadline: deadline,
      created_at: created_at,
      updated_at: updated_at,
      # participants: decision_participants.map(&:api_json),
      # options: options.map(&:api_json),
      # approvals: approvals.map(&:api_json),
      # results: results.map(&:api_json),
      # history_events: history_events.map(&:api_json),
      # backlinks: backlinks.map(&:api_json),
    }
    if include.include?('participants')
      response.merge!({ participants: participants.map(&:api_json) })
    end
    if include.include?('options')
      response.merge!({ options: options.map(&:api_json) })
    end
    if include.include?('approvals')
      response.merge!({ approvals: approvals.map(&:api_json) })
    end
    if include.include?('results')
      response.merge!({ results: results.map(&:api_json) })
    end
    if include.include?('backlinks')
      response.merge!({ backlinks: backlinks.map(&:api_json) })
    end
    response
  end

  def title
    question
  end

  def participants
    decision_participants
  end

  def can_add_options?(participant)
    return false if closed?
    return false if !participant.authenticated?
    return true if options_open?
    return true if participant == created_by
    return false if participant.nil?
  end

  def can_update_options?(participant)
    can_add_options?(participant)
  end

  def can_delete_options?(participant)
    can_add_options?(participant)
  end

  def public?
    false
  end

  def results
    return @results if @results
    @results = DecisionResult.where(
      tenant_id: tenant_id,
      decision_id: self.id
    ).map.with_index do |result, index|
      result.position = index + 1
      result
    end
  end

  def view_count
    participants.count
  end

  def option_contributor_count
    options.distinct.count(:decision_participant_id)
  end

  def voter_count
    approvals.distinct.count(:decision_participant_id)
  end

  def path_prefix
    'd'
  end

end
