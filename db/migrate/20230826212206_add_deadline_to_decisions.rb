class AddDeadlineToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :deadline, :datetime
  end
end
