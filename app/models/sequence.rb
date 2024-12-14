class Sequence < ApplicationRecord
  include HasTruncatedId
  include Pinnable
  include Linkable
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :paused_by, class_name: 'User', optional: true
  belongs_to :resumed_by, class_name: 'User', optional: true

  validates :title, presence: true
  validates :item_type, inclusion: { in: ['Note', 'Decision', 'Commitment'] }

  validate :validate_settings_schema

  before_validation :set_starts_at
  before_validation :set_defaults

  after_create do
    create_next_item_and_schedule!
  end

  def set_tenant_id
    self.tenant_id ||= Tenant.current_tenant_id
  end

  def set_studio_id
    self.studio_id ||= Studio.current_studio_id
  end

  def set_starts_at
    self.starts_at ||= Time.current
  end

  def set_defaults
    self.settings = ({
      cycle_unit: 'week',
      cycle_subunit: 'day',
      pattern: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
      template: {
        options_open: true,
        options: [],
        critical_mass: 1,
      },
    }).merge(settings || {})
  end

  def validate_settings_schema
    return unless settings
    schema = {
      type: 'object',
      properties: {
        cycle_unit: { type: 'string', enum: ['minute', 'hour', 'day', 'week', 'month'] },
        cycle_subunit: { type: 'string', enum: ['minute', 'hour', 'day'] },
        pattern: { type: 'array', items: { type: 'string', enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'] } },
        template: {
          type: 'object',
          properties: {
            options_open: { type: 'boolean' },
            options: {
              type: 'array',
              items: {
                type: 'string',
              },
            },
            critical_mass: { type: 'integer', minimum: 1 },
          },
        },
      },
    }
    JSON::Validator.validate!(schema, settings)
  end

  def path_prefix
    'sq'
  end

  def completed?
    ends_at && Time.current > ends_at
  end

  def completed_at
    return nil unless completed?
    ends_at
  end

  def completed_or_paused?
    completed? || paused?
  end

  def paused?
    paused_at.present? && Time.current > paused_at
  end

  def api_json(include: [])
    response = {
      id: id,
      truncated_id: truncated_id,
      title: title,
      tempo: tempo,
      item_type: item_type,
      created_at: created_at,
      updated_at: updated_at,
      created_by_id: created_by_id,
      updated_by_id: updated_by_id,
      starts_at: starts_at,
      ends_at: ends_at,
    }
    if include.include?(:items)
      items = self.items.map { |item| item.api_json }
      response[:items] = items
    end
    response
  end

  def template
    ({
      title: title,
      description: description,
    }).merge(settings['template'])
  end

  def options_open
    template['options_open']
  end

  def items
    return @items if defined?(@items)
    items!
  end

  def items!
    @items = item_type.constantize.where(sequence: self).order(sequence_position: :desc)
  end

  def last_item
    return @last_item if defined?(@last_item)
    last_item!
  end

  def last_item!
    @last_item = items.order(sequence_position: :desc).first
  end

  def current_item
    return nil if ends_at && Time.current > ends_at
    last_item
  end

  def past_items
    items.order(sequence_position: :desc).offset(1)
  end

  def item_count
    items.count
  end

  def cycle_unit
    settings['cycle_unit']
  end

  def cycle_duration
    1.send(cycle_unit)
  end

  def time_elapsed
    Time.current - self.starts_at
  end

  def cycles_elapsed
    time_elapsed.to_f / cycle_duration
  end

  def current_cycle
    cycles_elapsed.floor
  end

  def next_cycle
    current_cycle + 1
  end

  def time_until_next_item
    return 0.send(cycle_unit) if last_item.nil?
    (next_cycle - cycles_elapsed).send(cycle_unit)
  end

  def next_item_scheduled_at
    time_until_next_item.from_now
  end

  def next_item_position
    last_item ? last_item.sequence_position + 1 : 1
  end

  def create_next_item_and_schedule!
    ActiveRecord::Base.transaction do
      if last_item&.interaction_count == 0
        self.paused_at = Time.current
        self.paused_by_id = studio.trustee_user_id
        save!
        SequenceHistoryEvent.create!(
          sequence: self,
          user: studio.trustee_user,
          event_type: 'pause',
          happened_at: Time.current,
          data: {
            paused_at: paused_at,
            paused_by_id: paused_by_id,
            reason: 'Last item had 0 interactions',
          }
        )
      else
        create_next_item! if time_for_next_item?
        schedule_next_item!
      end
    end
  end

  def time_for_next_item?
    return false if completed_or_paused?
    return false if starts_at > Time.current
    return true if last_item.nil?
    deadline_for_position(last_item.sequence_position) < Time.current
  end

  def deadline_for_position(position)
    starts_at + position.send(cycle_unit)
  end

  def can_create_next_item?
    return false if completed_or_paused?
    last_item.nil? || last_item.interaction_count > 0
  end

  def create_next_item!
    return unless can_create_next_item?
    ActiveRecord::Base.transaction do
      @last_item = item_type.constantize.create_from_sequence!(self, next_item_position)
      SequenceHistoryEvent.create!(
        sequence: self,
        user: studio.trustee_user,
        event_type: 'item_create',
        happened_at: Time.current,
        data: {
          item_id: @last_item.id,
        }
      )
    end
    items! # refresh items
    @last_item
  end

  def schedule_next_item!
    CreateSequenceItemJob.set(wait_until: next_item_scheduled_at).perform_later(self)
  end

  def metric_name
    'items'
  end

  def metric_value
    item_count
  end

  def octicon_metric_icon_name
    'list-ordered'
  end

end