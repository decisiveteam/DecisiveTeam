class Commitment < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  has_many :participants, class_name: 'CommitmentParticipant'
  validates :title, presence: true
  validates :critical_mass, presence: true, numericality: { greater_than: 0 }
  validates :deadline, presence: true

  def truncated_id
    # TODO Fix the bug that causes this to be nil on first save
    super || self.id.to_s[0..7]
  end

  def path_prefix
    'c'
  end

  def status_message
    # critical mass achieved
    return 'Critical mass achieved.' if critical_mass_achieved?
    # critical mass not achieved
    return 'Failed to reach critical mass.' if closed?
    # critical mass not achieved yet
    return "Pending"
  end

  def committed_participants
    participants.where.not(committed_at: nil)
  end

  def participant_count
    committed_participants.count
  end

  def remaining_needed_for_critical_mass
    [critical_mass - participant_count, 0].max
  end

  def critical_mass_achieved?
    participant_count >= critical_mass
  end

  def progress_percentage
    return 100 if critical_mass_achieved?
    [(participant_count.to_f / critical_mass.to_f * 100).round, 100].min
  end
end