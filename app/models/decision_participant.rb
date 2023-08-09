class DecisionParticipant < ApplicationRecord
  belongs_to :decision
  belongs_to :entity, polymorphic: true, optional: true

  has_many :approvals, dependent: :destroy
  has_many :options, dependent: :destroy
end
