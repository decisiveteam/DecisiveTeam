class Tenant < ApplicationRecord
  self.implicit_order_column = "created_at"
  # Loop through all tables except tenants, users, and rails internal tables
  tables = ActiveRecord::Base.connection.tables - [
    'tenants', 'users', 'ar_internal_metadata', 'schema_migrations'
  ]
  tables.each do |table|
    has_many table.to_sym
  end

  def self.scope_thread_to_tenant(subdomain:)
    tenant = find_by(subdomain: subdomain)
    if tenant
      self.current_subdomain = tenant.subdomain
      self.current_id = tenant.id
    else
      raise "Invalid subdomain"
    end
    tenant
  end

  def self.current_subdomain
    Thread.current[:tenant_subdomain]
  end

  def self.current_id
    Thread.current[:tenant_id]
  end

  private

  def self.current_subdomain=(subdomain)
    Thread.current[:tenant_subdomain] = subdomain
  end

  def self.current_id=(id)
    Thread.current[:tenant_id] = id
  end
end
