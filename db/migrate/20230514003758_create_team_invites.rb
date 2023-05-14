class CreateTeamInvites < ActiveRecord::Migration[7.0]
  def change
    create_table :team_invites do |t|
      t.references :team, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :code, null: false, index: { unique: true }
      t.datetime :expires_at, null: false
      t.integer :max_uses, null: false, default: 1
      t.integer :uses, null: false, default: 0

      t.timestamps
    end
  end
end
