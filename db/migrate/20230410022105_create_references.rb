class CreateReferences < ActiveRecord::Migration[7.0]
  def change
    create_table :references do |t|
      t.integer :referencer_team_id
      t.integer :referencer_decision_id
      t.references :referencer, null: false, polymorphic: true
      t.string :referencer_attribute

      t.integer :referenced_team_id
      t.integer :referenced_decision_id
      t.references :referenced, null: false, polymorphic: true
      t.references :created_by, null: false, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
