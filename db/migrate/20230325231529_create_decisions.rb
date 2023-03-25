class CreateDecisions < ActiveRecord::Migration[7.0]
  def change
    create_table :decisions do |t|
      t.text :context
      t.text :question
      t.string :status
      t.datetime :deadline
      t.references :created_by, team_member: true, null: false, foreign_key: true
      t.references :decision_log, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.json :external_ids

      t.timestamps
    end
  end
end
