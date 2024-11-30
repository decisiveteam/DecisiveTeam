class CustomDataRecord < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :updated_by, class_name: 'User', foreign_key: 'updated_by_id'
  belongs_to :table, class_name: 'CustomDataTable', foreign_key: 'table_id'
  has_many :custom_data_associations, foreign_key: 'child_record_id'
  has_many :parent_records, through: :custom_data_associations, source: :parent_record, class_name: 'CustomDataRecord'
  has_many :history_events, class_name: 'CustomDataHistoryEvent'

  def self.create_with_history_event!(attributes:, request_context:, user:)
    ActiveRecord::Base.transaction do
      unless attributes && request_context && user
        raise ArgumentError, "attributes, request_context, and user are required"
      end
      unless attributes[:table_name] && attributes[:data]
        raise ArgumentError, "table_name and data are required"
      end
      table = CustomDataTable.find_or_create_by!(name: attributes[:table_name])
      data = data_from_attributes(attributes)
      record = self.new({
        table: table,
        custom_uid: attributes[:custom_uid],
        data: data,
        created_by: user,
        updated_by: user,
      })
      table.enforce_or_update_schema!(data)
      record.save!
      if attributes[:belongs_to].present?
        attributes[:belongs_to].each do |parent_record|
          unless parent_record.is_a?(CustomDataRecord)
            raise ArgumentError, "belongs_to must be an array of CustomDataRecord instances"
          end
          CustomDataAssociation.create!(
            parent_record: parent_record,
            child_record: record
          )
        end
      end
      record.history_events.create!(
        user: user,
        happened_at: record.created_at,
        event_type: 'create',
        event_data: {
          request_context: request_context,
          data: record.data,
        }
      )
      return record
    end
  end

  def self.data_from_attributes(attributes)
    attributes[:data].is_a?(Hash) ? attributes[:data] : attributes[:data].permit!.to_h
  end

  def table_name
    table.name
  end

  def parents
    # CustomDataAssociation.includes(:parent_record).where(child_record: self).map(&:parent_record)
    parent_records
  end

  def belongs_to
    parents
  end

  def children
    CustomDataAssociation.includes(:child_record).where(parent_record: self).map(&:child_record)
  end

  def set_tenant_id
    self.tenant_id ||= created_by.tenant_id
  end

  def update_with_history_event!(attributes:, request_context:, user:)
    ActiveRecord::Base.transaction do
      unless attributes && request_context && user
        raise ArgumentError, "attributes, request_context, and user are required"
      end
      self.data = self.class.data_from_attributes(attributes)
      table.enforce_or_update_schema!(self.data)
      self.updated_by = user
      if attributes[:belongs_to].present?
        existing_parents = self.parents
        attributes[:belongs_to].each do |parent_record|
          unless parent_record.is_a?(CustomDataRecord)
            raise ArgumentError, "belongs_to must be an array of CustomDataRecord instances"
          end
          unless existing_parents.include?(parent_record)
            CustomDataAssociation.create!(
              parent_record: parent_record,
              child_record: self
            )
          end
        end
        (existing_parents - attributes[:belongs_to]).each do |parent_record|
          CustomDataAssociation.find_by(
            parent_record: parent_record,
            child_record: self
          ).destroy!
        end
      end
      self.save!
      self.history_events.create!(
        user: user,
        happened_at: updated_at,
        event_type: 'update',
        event_data: {
          request_context: request_context,
          data: self.data,
        }
      )
    end
    self
  end

  def destroy_with_history_event!(request_context:, user:)
    ActiveRecord::Base.transaction do
      unless request_context && user
        raise ArgumentError, "request_context and user are required"
      end
      self.deleted_at = Time.now
      self.updated_by = user
      self.save!
      self.history_events.create!(
        user: user,
        happened_at: Time.now,
        event_type: 'delete',
        event_data: {
          request_context: request_context,
          data: self.data,
        }
      )
    end
    self
  end

  def create_read_history_event!(request_context:, user:)
    self.history_events.create!(
      user: user,
      happened_at: Time.now,
      event_type: 'read',
      event_data: {
        request_context: request_context,
        data: self.data,
      }
    )
  end

  # table_name is an optional argument to avoid an N+1 query
  def api_json(include: [], table_name: self.table_name)
    response = {
      id: id,
      table_name: table_name,
      custom_uid: custom_uid,
      data: data,
      created_at: created_at,
      updated_at: updated_at,
      deleted_at: deleted_at,
      created_by_id: created_by_id,
      updated_by_id: updated_by_id,
    }
    if include.include?('belongs_to')
      response.merge!({ belongs_to: belongs_to.map(&:api_json) })
    end
    if include.include?('history_events')
      response.merge!({ history_events: history_events.map(&:api_json) })
    end
    response
  end

end