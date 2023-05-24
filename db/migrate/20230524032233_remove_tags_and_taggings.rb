class RemoveTagsAndTaggings < ActiveRecord::Migration[7.0]
  def up
    drop_table :taggings
    drop_table :tags
  end

  def down
    create_table :tags do |t|
      t.string :name
      t.text :description
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.string :key

      t.timestamps
    end

    add_index :tags, [:team_id, :name], unique: true
    add_index :taggings, [:tag_id, :taggable_type, :taggable_id, :key], unique: true, name: 'index_taggings_on_tag_taggable_and_key'
  end
end
