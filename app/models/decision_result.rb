class DecisionResult < ApplicationRecord
  self.primary_key = "option_id"
  self.table_name = "decision_results" # view

  def get_sorting_factor(other_result)
    if self.approved_yes != other_result.approved_yes
      'approved_yes'
    elsif self.stars != other_result.stars
      'stars'
    else
      'random_id'
    end
  end

  def is_sorting_factor?(other_result, factor)
    return false if other_result.nil?
    get_sorting_factor(other_result) == factor
  end
end
