class CustomDataConfig < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  before_validation :set_defaults

  def set_tenant_id
    self.tenant_id ||= Tenant.current_id
  end

  def set_studio_id
    self.studio_id ||= Studio.current_id
  end

  def set_defaults
    self.config ||= self.class.default_config
  end

  def self.default_config
    {
      allow_dynamic_schema: true,
      schema: {
        dynamic: true,
      }
    }
  end

end