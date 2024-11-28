class TenantUser < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  belongs_to :user
  before_create :set_defaults

  def set_defaults
    self.handle ||= user.email
    self.display_name ||= user.name
    self.settings ||= {}
    self.settings['pinned'] ||= []
    self.settings['scratchpad'] ||= default_scratchpad
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

  def pinned_items
    settings['pinned'].map do |item|
      item['type'].constantize.find_by(id: item['id'])
    end
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
