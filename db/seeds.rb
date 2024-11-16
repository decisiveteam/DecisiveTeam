subdomain = ENV['PRIMARY_SUBDOMAIN'] || ''
tenant = Tenant.find_by(subdomain: subdomain)
if tenant.nil?
  tenant = Tenant.create!(subdomain: subdomain, name: 'Default')
end
