class Tenant < ApplicationRecord
  self.implicit_order_column = "created_at"
  # Loop through all tables except tenants, users, and rails internal tables
  tables = ActiveRecord::Base.connection.tables - [
    'tenants', 'users', 'ar_internal_metadata', 'schema_migrations'
  ]
  tables.each do |table|
    has_many table.to_sym
  end
  # has_many :users, through: :tenant_users
  before_create :set_defaults
  after_create :create_welcome_note

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

  def set_defaults
    self.settings ||= {}
    self.settings['pinned'] ||= []
  end

  def create_welcome_note!
    note = Note.create!(
      tenant: self,
      title: 'Welcome to Harmonic Team',
      text: 'This is a system generated note.'
    )
    pin_item!(note)
  end

  def pin_item!(item)
    pin_items!([item])
  end

  def pin_items!(items)
    self.settings['pinned'] += items.map do |item|
      {
        type: item.class.to_s,
        id: item.id
      }
    end
    save!
  end

  def add_user!(user)
    tenant_users.create!(
      user: user,
      display_name: user.name,
      handle: user.name.parameterize
    )
  end

  def team(limit: 100)
    tenant_users.includes(:user).limit(limit).map do |tu|
      tu.user.tenant_user = tu
      tu.user
    end
  end

  def is_admin?(user)
    # TODO - implement
    tenant_users.find_by(user: user).present?
  end

  def pinned_items
    settings['pinned'].map do |item|
      item['type'].constantize.find_by(id: item['id'])
    end
  end

  def open_items
    open_decisions = decisions.where('deadline > ?', Time.current)
    open_commitments = commitments.where('deadline > ?', Time.current)
    (open_decisions + open_commitments).sort_by(&:deadline)
  end

  def recently_closed_items(time_window: 1.week)
    closed_decisions = decisions.where('deadline < ?', Time.current).where('deadline > ?', time_window.ago)
    closed_commitments = commitments.where('deadline < ?', Time.current).where('deadline > ?', time_window.ago)
    (closed_decisions + closed_commitments).sort_by(&:deadline).reverse
  end

  def backlink_leaderboard(start_date: nil, end_date: nil, limit: 10)
    Link.backlink_leaderboard(tenant_id: self.id)
  end

  def auth_providers
    settings['auth_providers'] || ['github']
  end

  def require_login?
    settings['require_login'].to_s == 'false' ? false : true
  end

  def url
    "https://#{subdomain}.#{ENV['HOSTNAME']}"
  end

  private

  def self.current_subdomain=(subdomain)
    Thread.current[:tenant_subdomain] = subdomain
  end

  def self.current_id=(id)
    Thread.current[:tenant_id] = id
  end
end
