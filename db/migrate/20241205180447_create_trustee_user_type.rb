class CreateTrusteeUserType < ActiveRecord::Migration[7.0]
  # Trustee users represent relationships between users that allow one user to act on behalf of another user.
  # Trustee users also enable users to act as representatives of studios within other studios.
  def change
    # Add user_type column to users table
    add_column :users, :user_type, :string, default: 'person' # 'simulated', 'trustee'
    # Update existing users to have the correct user_type
    User.update_all(user_type: 'person')
    User.where(simulated: true).update_all(user_type: 'simulated')
    # Remove redundant simulated column
    remove_column :users, :simulated, :boolean
    # Create trustee_permissions table
    create_table :trustee_permissions, id: :uuid do |t|
      # The trustee user is the user of type 'trustee' that the trusted user impersonates when acting on behalf of the granting user.
      t.references :trustee_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      # The granting and trusted users are the users in the relationship.
      t.references :granting_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.references :trusted_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.text :description, null: false, default: ''
      # The relationship_phrase is basically the username of the relationship, e.g. "Alice on behalf of Bob",
      # "Alice representing Bob while Bob is on vaction", "Alice as Bob's assistant", "Alice as Bob's delegate", etc.
      t.string :relationship_phrase, null: false, default: '{trusted_user} on behalf of {granting_user}'
      t.jsonb :permissions, default: {}
      t.datetime :expires_at, null: true
      t.timestamps
      # Note that this table does not have a tenant_id column because users are not tenant specific.
    end
    # Studio trustees allow studios to act as a singular entity within other studios via a representative user.
    create_table :studio_trustees, id: :uuid do |t|
      t.references :tenant, null: false, foreign_key: true, type: :uuid
      t.references :studio, null: false, foreign_key: true, type: :uuid
      t.references :trustee_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.jsonb :settings, default: {}
      t.timestamps
    end
    # Only one studio trustee per studio (and studios are a subset of tenants)
    add_index :studio_trustees, [:tenant_id, :studio_id, :trustee_user_id], unique: true, name: 'studio_trustees_unique_index'
  end
end
