class DecisionParticipant < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :decision
  has_one :created_decision, class_name: 'Decision', foreign_key: 'created_by_id'

  has_many :approvals, dependent: :destroy
  has_many :options, dependent: :destroy
end
