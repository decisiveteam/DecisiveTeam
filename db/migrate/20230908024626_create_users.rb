class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :auth0_id, null: false
      t.string :email, null: false, default: ""
      t.string :name, null: false, default: ""
      t.string :picture_url
      t.json :metadata

      t.timestamps
    end

    add_index :users, :auth0_id, unique: true
    add_index :users, :email, unique: true
  end
end
