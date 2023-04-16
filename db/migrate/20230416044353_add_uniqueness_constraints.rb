class AddUniquenessConstraints < ActiveRecord::Migration[7.0]
  def change
    add_index :teams, :handle, unique: true
    add_index :team_members, [:team_id, :user_id], unique: true
    add_index :options, [:decision_id, :title], unique: true
    add_index :approvals, [:option_id, :created_by_id], unique: true
    add_index :tags, [:team_id, :name], unique: true
    add_index :taggings, [:tag_id, :taggable_type, :taggable_id, :key], unique: true, name: 'index_taggings_on_tag_taggable_and_key'
  end
end
