class AddOwnerIdToOauthApplications < ActiveRecord::Migration[7.0]
  def change
    add_column :oauth_applications, :owner_id, :integer
    add_foreign_key :oauth_applications, :users, column: :owner_id
    add_index :oauth_applications, :owner_id
  end
end
