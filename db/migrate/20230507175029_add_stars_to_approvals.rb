class AddStarsToApprovals < ActiveRecord::Migration[7.0]
  def change
    add_column :approvals, :stars, :integer, default: 0
  end
end
