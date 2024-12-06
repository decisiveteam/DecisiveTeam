class Tenant < ApplicationRecord
  self.implicit_order_column = "created_at"
  has_many :tenant_users
  has_many :users, through: :tenant_users
  belongs_to :main_studio, class_name: 'Studio'
  before_create :set_defaults
  after_create :create_main_studio!

  tables = ActiveRecord::Base.connection.tables - [
    'tenants', 'users', 'oauth_identities',
    'ar_internal_metadata', 'schema_migrations'

  ]
  tables.each do |table|
    has_many table.to_sym
  end

  def self.scope_thread_to_tenant(subdomain:)
    if subdomain == ENV['AUTH_SUBDOMAIN']
      tenant = Tenant.new(
        id: SecureRandom.uuid,
        name: 'Harmonic Team',
        subdomain: ENV['AUTH_SUBDOMAIN'],
        settings: { 'require_login' => false }
      )
    else
      tenant = find_by(subdomain: subdomain)
    end
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

  def path
    "/"
  end

  def set_defaults
    self.settings = ({
      timezone: 'UTC',
      require_login: true,
    }).merge(self.settings || {})
  end

  def timezone=(value)
    if value.present?
      @timezone = ActiveSupport::TimeZone[value]
      set_defaults
      self.settings = self.settings.merge('timezone' => @timezone.name)
      self.main_studio.timezone = @timezone.name
      self.main_studio.save!
    end
  end

  def timezone
    @timezone ||= self.settings['timezone'] ? ActiveSupport::TimeZone[self.settings['timezone']] : ActiveSupport::TimeZone['UTC']
  end

  def create_main_studio!
    self.main_studio = studios.create!(
      name: "#{self.subdomain}.#{ENV['HOSTNAME']}",
      handle: SecureRandom.hex(16)
    )
    save!
  end

  def add_user!(user)
    tenant_users.create!(
      user: user,
      display_name: user.name,
      handle: user.name.parameterize
    )
  end

  def description
    settings['description']
  end

  def team(limit: 100)
    tenant_users
      .where(archived_at: nil)
      .includes(:user)
      .limit(limit)
      .order(created_at: :desc).map do |tu|
        tu.user.tenant_user = tu
        tu.user
    end
  end

  def is_admin?(user)
    tu = tenant_users.find_by(user: user)
    tu && tu.roles.include?('admin')
  end

  def admin_users
    tenant_users.where_has_role('admin')
  end

  def auth_providers
    settings['auth_providers'] || ['github']
  end

  def require_login?
    settings['require_login'].to_s == 'false' ? false : true
  end

  def domain
    "#{subdomain}.#{ENV['HOSTNAME']}"
  end

  def url
    "https://#{domain}"
  end

  private

  def self.current_subdomain=(subdomain)
    Thread.current[:tenant_subdomain] = subdomain
  end

  def self.current_id=(id)
    Thread.current[:tenant_id] = id
  end
end
