# app/models/concerns/my_mixin.rb
module Tracked
  extend ActiveSupport::Concern

  included do
    after_create :track_creation
    after_update :track_changes
    after_destroy :track_deletion
  end

  def track_creation
    # TODO, actually track changes
    SendWebhookJob.perform_later(
      'https://eovsh6w1yhbr2nk.m.pipedream.net',
      { event: "#{self.class.name.underscore}:created", data: self.attributes }
    )
  end

  def track_changes
    # TODO, actually track changes
    SendWebhookJob.perform_later(
      'https://eovsh6w1yhbr2nk.m.pipedream.net',
      { event: "#{self.class.name.underscore}:updated", data: saved_changes }
    )
  end

  def track_deletion
    # TODO, actually track changes
    SendWebhookJob.perform_later(
      'https://eovsh6w1yhbr2nk.m.pipedream.net',
      { event: "#{self.class.name.underscore}:deleted", data: self.attributes }
    )
  end

  class_methods do
    def is_tracked?
      true
    end
  end
end
