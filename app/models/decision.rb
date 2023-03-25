class Decision < ApplicationRecord
  belongs_to :created_by
  belongs_to :decision_log
  belongs_to :team
end
