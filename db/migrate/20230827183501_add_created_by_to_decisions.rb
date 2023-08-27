class AddCreatedByToDecisions < ActiveRecord::Migration[7.0]
  def change
    add_column :decisions, :created_by_id, :uuid, index: true
    add_foreign_key :decisions, :decision_participants, column: :created_by_id
  end
end
