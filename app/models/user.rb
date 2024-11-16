class User < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :decision_participants
  has_many :commitment_participants
  has_many :note_history_events
end