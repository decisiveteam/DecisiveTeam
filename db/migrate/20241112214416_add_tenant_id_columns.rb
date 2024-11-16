class AddTenantIdColumns < ActiveRecord::Migration[7.0]
  def change
    # Loop through all tables except users, tenants, and rails internal tables
    tables = ActiveRecord::Base.connection.tables - ['users', 'tenants', 'ar_internal_metadata', 'schema_migrations']
    default_tenant = Tenant.first
    if default_tenant.nil?
      subdomain = ENV['PRIMARY_SUBDOMAIN'] || ''
      default_tenant = Tenant.create!(subdomain: subdomain, name: 'Default')
    end
    default_tenant_id = default_tenant.id
    tables.each do |table|
      # Add column as a reference to the tenant
      add_reference table, :tenant, type: :uuid, foreign_key: true, null: false, default: default_tenant_id
      # Remove default value for tenant_id
      change_column_default table, :tenant_id, from: default_tenant_id, to: nil
    end
  end
end
