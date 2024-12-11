class AddSettingsToStudioUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :studio_users, :settings, :jsonb, default: {}
  end
end
