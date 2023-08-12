class AddTruncatedIdToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :truncated_id, :string, null: false, as: 'LEFT(id::text, 8)', stored: true
    add_index :decisions, :truncated_id, unique: true
  end
end
