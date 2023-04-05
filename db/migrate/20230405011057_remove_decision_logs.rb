class RemoveDecisionLogs < ActiveRecord::Migration[7.0]
  def up
    # Remove foreign key constraints from decisions and webhooks tables
    remove_foreign_key :decisions, :decision_logs
    remove_foreign_key :webhooks, :decision_logs

    # Remove decision_log_id column from decisions and webhooks tables
    remove_column :decisions, :decision_log_id
    remove_column :webhooks, :decision_log_id

    # Drop the decision_logs table
    drop_table :decision_logs
  end

  def down
    # Recreate the decision_logs table
    create_table :decision_logs do |t|
      t.string :title
      t.references :team, null: false, foreign_key: true
      t.json :external_ids

      t.timestamps
    end

    # Add decision_log_id column to decisions and webhooks tables
    add_column :decisions, :decision_log_id, :integer
    add_column :webhooks, :decision_log_id, :integer

    # Add foreign key constraints to decisions and webhooks tables
    add_foreign_key :decisions, :decision_logs
    add_foreign_key :webhooks, :decision_logs

    # Add index to decision_log_id columns
    add_index :decisions, :decision_log_id
    add_index :webhooks, :decision_log_id
  end
end
