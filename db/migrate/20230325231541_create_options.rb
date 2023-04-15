class CreateOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :options do |t|
      t.text :title
      t.text :description
      t.references :created_by, team_member: true, null: false, foreign_key: { to_table: :users }
      t.references :decision, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.jsonb :external_ids

      t.timestamps
    end
  end
end
