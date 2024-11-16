class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  default_scope do
    if belongs_to_tenant? && Tenant.current_id
      where(tenant_id: Tenant.current_id)
    else
      all
    end
  end

  def self.belongs_to_tenant?
    self.column_names.include?("tenant_id")
  end

  def set_tenant_id
    self.tenant_id ||= Tenant.current_id
  end

  def self.is_tracked?
    false
  end

  def is_tracked?
    self.class.is_tracked?
  end

  def deadline_iso8601
    if deadline
      deadline.iso8601
    else
      ""
    end
  end

  def closed?
    deadline && deadline < Time.now
  end

  def path
    "/#{path_prefix}/#{self.truncated_id}"
  end

  def shareable_link
    subdomain = self.tenant.subdomain
    domain = ENV['HOSTNAME']
    fulldomain = subdomain.present? ? "#{subdomain}.#{domain}" : domain
    "https://#{fulldomain}#{path}"
  end

end
