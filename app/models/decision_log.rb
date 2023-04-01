class DecisionLog < ApplicationRecord
  include Tracked
  belongs_to :team
  has_many :decisions
end
