class RemoveStatusAndDeadlineFromDecisions < ActiveRecord::Migration[7.0]
  def change
    remove_column :decisions, :status, :string
    remove_column :decisions, :deadline, :datetime
  end
end
