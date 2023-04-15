class CreateTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_members do |t|
      t.string :name
      t.string :status
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :external_ids

      t.timestamps
    end
  end
end
