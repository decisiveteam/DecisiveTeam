class Approval < ApplicationRecord
  include Tracked
  belongs_to :option
  belongs_to :decision
  belongs_to :decision_participant
  belongs_to :team

  validates :value, inclusion: { in: [0, 1] }
  validates :stars, inclusion: { in: [0, 1] }

  def accessible_by(user)
    super.or(user.approvals)
  end
end
