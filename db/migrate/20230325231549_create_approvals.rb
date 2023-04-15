class CreateApprovals < ActiveRecord::Migration[7.0]
  def change
    create_table :approvals do |t|
      t.integer :value
      t.text :note
      t.references :option, null: false, foreign_key: true
      t.references :decision, null: false, foreign_key: true
      t.references :created_by, team_member: true, null: false, foreign_key: { to_table: :users }
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
