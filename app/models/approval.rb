class Approval < ApplicationRecord
  belongs_to :option
  belongs_to :decision
  belongs_to :created_by
  belongs_to :team
end
