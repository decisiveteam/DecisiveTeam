class Approval < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  belongs_to :option
  belongs_to :decision
  belongs_to :decision_participant

  validates :value, inclusion: { in: [0, 1] }
  validates :stars, inclusion: { in: [0, 1] }
end
