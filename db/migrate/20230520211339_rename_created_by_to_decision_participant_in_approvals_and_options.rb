class RenameCreatedByToDecisionParticipantInApprovalsAndOptions < ActiveRecord::Migration[7.0]
  def up
    remove_foreign_key :approvals, :users, column: :created_by_id
    remove_foreign_key :options, :users, column: :created_by_id

    execute <<-SQL
      INSERT INTO decision_participants(decision_id, entity_id, entity_type, created_at, updated_at)
      SELECT DISTINCT decision_id, created_by_id, 'User', NOW(), NOW() FROM approvals
      UNION
      SELECT DISTINCT decision_id, created_by_id, 'User', NOW(), NOW() FROM options;
    SQL

    rename_column :approvals, :created_by_id, :decision_participant_id
    rename_column :options, :created_by_id, :decision_participant_id

    execute <<-SQL
      UPDATE approvals
      SET decision_participant_id = (SELECT id FROM decision_participants WHERE entity_id = decision_participant_id LIMIT 1)
      WHERE EXISTS (SELECT 1 FROM decision_participants WHERE entity_id = decision_participant_id);
      
      UPDATE options
      SET decision_participant_id = (SELECT id FROM decision_participants WHERE entity_id = decision_participant_id LIMIT 1)
      WHERE EXISTS (SELECT 1 FROM decision_participants WHERE entity_id = decision_participant_id);
    SQL

    add_foreign_key :approvals, :decision_participants
    add_foreign_key :options, :decision_participants
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reversed."
  end
end
