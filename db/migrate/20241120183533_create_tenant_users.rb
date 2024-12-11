class CreateTenantUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :tenant_users, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :handle, null: false
      t.string :display_name, null: false
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end
    add_index :tenant_users, [:tenant_id, :user_id], unique: true
    add_index :tenant_users, [:tenant_id, :handle], unique: true
  end
end
