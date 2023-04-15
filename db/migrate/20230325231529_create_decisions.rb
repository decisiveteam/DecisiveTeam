class CreateDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :decisions do |t|
      t.text :context
      t.text :question
      t.string :status
      t.datetime :deadline
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :decision_log, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.jsonb :external_ids

      t.timestamps
    end
  end
end
