class Commitment < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"

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
    return "Pending. #{remaining_needed_for_critical_mass} more participant#{'s' if remaining_needed_for_critical_mass != 1} needed to reach critical mass."
  end


  # def critical_mass
  #   # temp debug
  #   20
  # end

  def participant_count
    #participants.count
    2
  end

  def remaining_needed_for_critical_mass
    critical_mass - participant_count
  end

  def critical_mass_achieved?
    participant_count >= critical_mass
  end
end