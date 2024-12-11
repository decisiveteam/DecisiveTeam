class AddSimulationColumnsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :simulated, :boolean, default: false
    add_column :users, :parent_id, :uuid, foreign_key: { to_table: :users }
    add_index :users, :parent_id
  end
end
