class Decision < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  has_many :decision_participants, dependent: :destroy
  has_many :options, dependent: :destroy
  has_many :approvals # dependent: :destroy through options
  validates :question, presence: true
  
  def participants
    decision_participants
  end

  def closed?
    false
  end

  def public?
    false
  end

  def results
    return @results if @results
    @results = DecisionResult.where(decision_id: self.id)
  end

  def voter_count
    approvals.distinct.count(:decision_participant_id)
  end

  def path
    "/decisions/#{self.id}"
  end

  def shareable_link
    "https://#{ENV['HOSTNAME']}#{path}"
  end
end
