class DecisionResult < ApplicationRecord
  self.primary_key = "option_id"
  self.table_name = "decision_results" # view
end
