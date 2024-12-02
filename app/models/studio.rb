class Studio < ApplicationRecord
  include CanPin
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_create :set_defaults
  tables = ActiveRecord::Base.connection.tables - [
    'tenants', 'users', 'tenant_users',
    'studios', 'api_tokens', 'oauth_identities',
    'ar_internal_metadata', 'schema_migrations'
  ]
  tables.each do |table|
    has_many table.to_sym
  end
  has_many :users, through: :studio_users

  validate :handle_is_valid

  def self.scope_thread_to_studio(subdomain:, handle:)
    tenant = Tenant.scope_thread_to_tenant(subdomain: subdomain)
    studio = handle ? tenant.studios.find_by!(handle: handle) : tenant.main_studio
    if studio.nil? && subdomain == ENV['AUTH_SUBDOMAIN']
      studio = Studio.new(
        id: SecureRandom.uuid,
        name: 'Harmonic Team',
        handle: SecureRandom.hex(16),
        tenant: tenant,
      )
      tenant.main_studio = studio
    end
    Thread.current[:studio_id] = studio.id
    Thread.current[:studio_handle] = studio.handle
    studio
  end

  def self.current_handle
    Thread.current[:studio_handle]
  end

  def self.current_id
    Thread.current[:studio_id]
  end

  def self.handle_available?(handle)
    Studio.where(handle: handle).count == 0
  end

  def set_defaults
    self.settings = {
      'unlisted' => false,
      'invite_only' => true,
    }.merge(self.settings || {})
    self.settings['pinned'] ||= {}
  end

  def timezone=(value)
    if value.present?
      @timezone = ActiveSupport::TimeZone[value]
      set_defaults
      self.settings = self.settings.merge('timezone' => @timezone.name)
    end
  end

  def timezone
    @timezone ||= self.settings['timezone'] ? ActiveSupport::TimeZone[self.settings['timezone']] : ActiveSupport::TimeZone['UTC']
  end

  def handle_is_valid
    if handle.present?
      only_alphanumeric_with_dash = handle.match?(/\A[a-z0-9-]+\z/)
      errors.add(:handle, "must be alphanumeric with dashes") unless only_alphanumeric_with_dash
    else
      errors.add(:handle, "can't be blank")
    end
  end

  def create_welcome_note!
    note = Note.create!(
      tenant: tenant,
      studio: self,
      title: 'Welcome to Harmonic Team',
      text: 'This is a system generated note.'
    )
    pin_item!(note)
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

  def is_main_studio?
    self.tenant.main_studio_id == self.id
  end

  def path_prefix
    's'
  end

  def path
    if is_main_studio?
      ''
    else
      "/#{path_prefix}/#{handle}"
    end
  end

  def url
    if handle
      "#{tenant.url}#{path}"
    else
      tenant.url
    end
  end

  def add_user!(user)
    studio_users.create!(
      tenant: tenant,
      user: user,
    )
  end

  def team(limit: 100)
    studio_users
      .where(archived_at: nil)
      .includes(:user)
      .limit(limit)
      .order(created_at: :desc).map do |su|
        su.user.studio_user = su
        su.user
      end
  end

  def backlink_leaderboard(start_date: nil, end_date: nil, limit: 10)
    Link.backlink_leaderboard(studio_id: self.id)
  end

  def delete!
    raise "Delete not implemented"
    raise "Cannot delete main studio" if is_main_studio?
    # self.archived_at = Time.current
    # save!
  end

  def find_or_create_shareable_invite(created_by)
    invite = StudioInvite.where(
      studio: self,
      invited_user: nil,
    ).where('expires_at > ?', Time.current + 2.days).first
    if invite.nil?
      invite = StudioInvite.create!(
        studio: self,
        created_by: created_by,
        code: SecureRandom.hex(16),
        expires_at: 1.week.from_now,
      )
    end
    invite
  end

end