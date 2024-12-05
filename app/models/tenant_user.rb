class TenantUser < ApplicationRecord
  include CanPin
  include HasRoles
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  belongs_to :user
  before_create :set_defaults

  def set_defaults
    self.handle ||= user.email
    self.display_name ||= user.name
    self.settings ||= {}
    self.settings['pinned'] ||= {}
    self.settings['scratchpad'] ||= {}
    self.settings['scratchpad'].merge!(default_scratchpad)
    self.roles ||= []
    self.roles << 'default'
  end

  def user
    @user ||= super
    @user.tenant_user ||= self
    @user
  end

  def archive!
    self.archived_at = Time.current
    save!
  end

  def unarchive!
    self.archived_at = nil
    save!
  end

  def archived?
    self.archived_at.present?
  end

  def path
    "/u/#{handle}"
  end

  def confirmed_read_note_events(limit: 10)
    NoteHistoryEvent.where(
      tenant_id: tenant_id,
      user_id: user_id,
      event_type: 'read_confirmation',
    ).includes(:note).order(happened_at: :desc).limit(limit)
  end

  def scratchpad
    settings['scratchpad'] || default_scratchpad
  end

  def scratchpad_links(tenant:, studio:)
    # Parse the text of the scratchpad and return an array of links
    links = []
    LinkParser.parse(scratchpad['text'], subdomain: tenant.subdomain, studio_handle: studio.handle) do |resource|
      links << {
        id: resource.truncated_id,
        url: resource.shareable_link,
        title: resource.title,
        type: resource.class.name,
      }
    end
    links
  end

  def default_scratchpad
    {
      'text' => default_scratchpad_text,
      'custom_json' => nil,
    }
  end

  def default_scratchpad_text
    <<~SCRATCH_PAD_TEXT
      # Scratch pad

      Anything you write here will be saved and accessible to you from any page. This text is only visible to you.

      The purpose of this feature is simply to provide a convenient place to save links and thoughts and any other info you might want to jot down so that you don't lose track of it.
    SCRATCH_PAD_TEXT
  end

end
