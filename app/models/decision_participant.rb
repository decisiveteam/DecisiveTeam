class DecisionParticipant < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :decision

  has_many :approvals, dependent: :destroy
  has_many :options, dependent: :destroy
end
