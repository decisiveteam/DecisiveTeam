class CycleDataRow < ApplicationRecord
  self.primary_key = "item_id"
  self.table_name = "cycle_data" # view
  belongs_to :tenant
  belongs_to :studio
  belongs_to :item, polymorphic: true
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  def self.valid_group_bys
    self.column_names + [
      'status', 'created_within_cycle', 'updated_within_cycle',
      'deadline_within_cycle', 'days_until_deadline'
    ]
  end

  def self.valid_sort_bys
    self.column_names
  end

  def cycle=(cycle)
    @cycle = cycle
  end

  def is_open
    deadline > Time.now
  end

  def status
    if is_open
      'open'
    else
      'closed'
    end
  end

  def created_within_cycle
    created_at >= @cycle.start_date && created_at <= @cycle.end_date
  end

  def updated_within_cycle
    updated_at >= @cycle.start_date && updated_at <= @cycle.end_date
  end

  def deadline_within_cycle
    deadline >= @cycle.start_date && deadline <= @cycle.end_date
  end

  def days_until_deadline
    (deadline.to_date - Time.now.to_date).to_i
  end

  def api_json
    {
      item_type: item_type,
      item_id: item_id,
      title: title,
      created_at: created_at,
      updated_at: updated_at,
      created_by: created_by&.api_json,
      updated_by: updated_by&.api_json,
      deadline: deadline,
      link_count: link_count,
      backlink_count: backlink_count,
      participant_count: participant_count,
      voter_count: voter_count,
      option_count: option_count,
      status: status,
    }
  end
end