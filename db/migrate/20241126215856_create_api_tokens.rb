class CreateApiTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :api_tokens, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :token, null: false
      t.datetime :last_used_at
      t.datetime :expires_at, default: -> { 'CURRENT_TIMESTAMP + INTERVAL \'1 year\'' }
      t.boolean :active, default: true
      t.jsonb :scopes, default: []

      t.timestamps
    end
    add_index :api_tokens, :token, unique: true
    add_index :api_tokens, [:tenant_id, :user_id]
  end
end
