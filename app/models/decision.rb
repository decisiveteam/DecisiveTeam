class Decision < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  has_many :decision_participants, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :approvals # dependent: :destroy through options
  belongs_to :created_by, class_name: 'DecisionParticipant', foreign_key: 'created_by_id', optional: true

  validates :question, presence: true

  def truncated_id
    # TODO Fix the bug that causes this to be nil on first save
    super || self.id.to_s[0..7]
  end

  def participants
    decision_participants
  end

  def can_add_options?(participant)
    return false if closed?
    return false if auth_required? && !participant.authenticated?
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

  def closed?
    deadline && deadline < Time.now
  end

  def public?
    false
  end

  def results
    return @results if @results
    @results = DecisionResult.where(decision_id: self.id)
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

  def path
    "/decisions/#{self.truncated_id}"
  end

  def shareable_link
    "https://#{ENV['HOSTNAME']}#{path}"
  end
end
