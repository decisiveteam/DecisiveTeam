class AddOptionsOpenToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :options_open, :boolean, default: true, null: false
    Decision.update_all(options_open: true)
  end
end
