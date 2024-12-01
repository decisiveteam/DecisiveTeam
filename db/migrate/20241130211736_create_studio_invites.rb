class CreateStudioInvites < ActiveRecord::Migration[7.0]
  def change
    create_table :studio_invites, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :studio, null: false, foreign_key: true, type: :uuid
      t.references :created_by, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :invited_user, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.string :code, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :studio_invites, :code, unique: true
  end
end
