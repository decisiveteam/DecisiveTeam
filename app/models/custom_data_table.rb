class CustomDataTable < ApplicationRecord
  self.implicit_order_column = "created_at"
  belongs_to :tenant
  before_validation :set_tenant_id
  belongs_to :studio
  before_validation :set_studio_id
  before_validation :set_defaults
  has_many :records, class_name: 'CustomDataRecord', foreign_key: 'table_id'

  validate :name_is_valid

  def self.default_config
    { 'schema' => { 'dynamic' => true, 'columns' => [] } }
  end

  def set_tenant_id
    self.tenant_id ||= Tenant.current_id
  end

  def set_studio_id
    self.studio_id ||= Studio.current_id
  end

  def set_defaults
    self.config ||= self.class.default_config
  end

  def schema
    config['schema'] || self.class.default_config['schema']
  end

  def records
    @records ||= super.where(deleted_at: nil)
  end

  def records_with_deleted
    CustomDataRecord.where(tenant_id: tenant_id, table: self)
  end

  def record_count
    records.count
  end

  def enforce_or_update_schema!(data)
    if schema['dynamic']
      update_schema!(data)
    else
      enforce_schema!(data)
    end
  end

  def enforce_schema!(data)
    raise "schema is dynamic" if schema['dynamic']
    raise ArgumentError, "schema is not defined" if schema['columns'].empty?
    column_names = schema['columns'].map { |column| column['name'] }.sort
    column_data_types_by_name = schema['columns'].map { |column| [column['name'], column['data_type']] }.to_h
    unless data.keys.sort == column_names
      raise ArgumentError, "data keys do not match schema columns"
    end
    data_conforms_to_schema = data.all? do |key, value|
      value_data_type = value.class # TODO convert to json data types
      if column_data_types_by_name[key] == 'any'
        true
      elsif column_data_types_by_name[key].is_a?(Array)
        column_data_types_by_name[key].include?(value_data_type)
      else
        column_data_types_by_name[key] == value_data_type
      end
    end
    # TODO - validate enum values
    # TODO - validate default values
    # TODO - validate nullable values
    unless data_conforms_to_schema
      raise ArgumentError, "data does not conform to schema"
    end
  end

  def update_schema!(data)
    column_names = schema['columns'].map { |column| column['name'] }
    column_names = (column_names + data.keys).uniq
    schema['columns'] = column_names.map do |column_name|
      {
        name: column_name,
        data_type: 'any',
        nullable: true,
        enum: nil,
        default: nil,
      }
    end
    self.config = (self.config || {}).merge('schema' => schema)
    save!
  end

  def last_updated
    records.maximum(:updated_at)
  end

  def find_record(id, include_deleted: false)
    recs = include_deleted ? records_with_deleted : records
    # if the id is a uuid, then we can't assume which column it is
    if id =~ /\A[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}\z/ # uuid
      recs.where('id = :id OR custom_uid = :id', id: id).first
    else
      recs.find_by(custom_uid: id)
    end
  end

  def scope_to_parent(parent_record)
    @records = records.joins(:custom_data_associations).where(custom_data_associations: { parent_record: parent_record })
    self
  end

  def name_is_valid
    unless name =~ /\A[a-z_]+\z/
      errors.add(:name, "must be lowercase snake_case")
    end
    if name.length > 255
      errors.add(:name, "must be 255 characters or less")
    end
    if name == 'history'
      errors.add(:name, "cannot be 'history'")
    end
  end

  def api_json(include: [])
    records.map { |record| record.api_json(include: include, table_name: name) }
  end

end