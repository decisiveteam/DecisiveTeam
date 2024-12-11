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
      t.string :truncated_id, null: false, as: 'LEFT(id::text, 8)', stored: true

      t.timestamps
    end
    add_index :representation_sessions, :truncated_id, unique: true
  end
end
