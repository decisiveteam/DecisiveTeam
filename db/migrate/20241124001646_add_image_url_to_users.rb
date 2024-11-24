class AddImageUrlToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :image_url, :string
  end
end
