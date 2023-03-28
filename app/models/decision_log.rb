class DecisionLog < ApplicationRecord
  include Tracked
  belongs_to :team
end
