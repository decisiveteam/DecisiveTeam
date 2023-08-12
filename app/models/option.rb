class Option < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  belongs_to :decision_participant
  belongs_to :decision

  has_many :approvals, dependent: :destroy
end
