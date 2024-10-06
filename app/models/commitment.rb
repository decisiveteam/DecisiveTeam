class Commitment < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"

  def truncated_id
    # TODO Fix the bug that causes this to be nil on first save
    super || self.id.to_s[0..7]
  end

  def path_prefix
    'c'
  end
end