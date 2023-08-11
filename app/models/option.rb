class Option < ApplicationRecord
  include Tracked
  belongs_to :decision_participant
  belongs_to :decision

  has_many :approvals, dependent: :destroy
end
