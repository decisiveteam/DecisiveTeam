class AddArchivedAtToTenantUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :tenant_users, :archived_at, :datetime
  end
end
