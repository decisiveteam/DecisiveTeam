class CreateRepresentationSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :representation_sessions, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :studio, null: false, foreign_key: true, type: :uuid
      t.references :representative_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :trustee_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :began_at, null: false
      t.datetime :ended_at
      t.boolean :confirmed_understanding, null: false, default: false
      t.jsonb :activity_log, default: {}

      t.timestamps
    end
  end
end
