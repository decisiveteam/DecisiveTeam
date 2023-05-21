class Option < ApplicationRecord
  include Tracked
  belongs_to :decision_participant
  belongs_to :decision
  belongs_to :team

  has_many :approvals, dependent: :destroy

  def accessible_by(user)
    super.or(user.options)
  end
end
