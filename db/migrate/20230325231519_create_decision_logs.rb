class CreateDecisionLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :decision_logs do |t|
      t.string :title
      t.references :team, null: false, foreign_key: true
      t.jsonb :external_ids

      t.timestamps
    end
  end
end
