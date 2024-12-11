class CreateOauthIdentities < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_identities, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :provider
      t.string :uid
      t.datetime :last_sign_in_at
      t.string :url
      t.string :username
      t.string :image_url
      t.jsonb :auth_data

      t.timestamps
    end
    add_index :oauth_identities, [:provider, :uid], unique: true
  end
end
