class Option < ApplicationRecord
  belongs_to :created_by
  belongs_to :decision
  belongs_to :team
end
