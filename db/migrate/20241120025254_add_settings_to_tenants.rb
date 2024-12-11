class AddSettingsToTenants < ActiveRecord::Migration[7.0]
  def change
    add_column :tenants, :settings, :jsonb, default: {}
  end
end
