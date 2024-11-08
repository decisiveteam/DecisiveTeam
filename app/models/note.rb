class Note < ApplicationRecord
  include Tracked
  self.implicit_order_column = "created_at"
  validates :title, presence: true

  def truncated_id
    # TODO Fix the bug that causes this to be nil on first save
    super || self.id.to_s[0..7]
  end

  def path_prefix
    'n'
  end
end