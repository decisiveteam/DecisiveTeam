class AddKeyToTaggings < ActiveRecord::Migration[7.0]
  def change
    add_column :taggings, :key, :string
  end
end
