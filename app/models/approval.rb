class Approval < ApplicationRecord
  include Tracked
  belongs_to :option
  belongs_to :decision
  belongs_to :decision_participant

  validates :value, inclusion: { in: [0, 1] }
  validates :stars, inclusion: { in: [0, 1] }
end
