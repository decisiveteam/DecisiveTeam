class AddNumberToDecisions < ActiveRecord::Migration[7.0]
  def up
    add_column :decisions, :number, :integer
    add_index :decisions, [:team_id, :number], unique: true

    # Update the number column for existing decision records
    execute <<-SQL
      DO $$
      DECLARE
        current_team_id INTEGER;
        decision_id INTEGER;
        decision_number INTEGER;
      BEGIN
        FOR current_team_id IN (SELECT DISTINCT team_id FROM decisions)
        LOOP
          decision_number := 1;
          FOR decision_id IN (
            SELECT id FROM decisions WHERE team_id = current_team_id ORDER BY created_at
          )
          LOOP
            UPDATE decisions SET number = decision_number WHERE id = decision_id;
            decision_number := decision_number + 1;
          END LOOP;
        END LOOP;
      END;
      $$;
    SQL
  end

  def down
    remove_index :decisions, column: [:team_id, :number]
    remove_column :decisions, :number
  end
end
