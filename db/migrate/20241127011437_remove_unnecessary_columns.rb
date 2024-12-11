class RemoveUnnecessaryColumns < ActiveRecord::Migration[7.0]
  def change
    remove_column :decisions, :auth_required, :boolean
    remove_column :decisions, :other_attributes, :jsonb
    remove_column :options, :other_attributes, :jsonb
    remove_column :users, :auth0_id, :string
    remove_column :users, :metadata, :jsonb
  end
end
