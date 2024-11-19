class LinkParser
  def self.parse(text, subdomain: nil)
    models = { 'n' => Note, 'c' => Commitment, 'd' => Decision }
    domain = "#{subdomain}.#{ENV['HOSTNAME']}"
    pattern = Regexp.new("https://#{domain}/([ncd])/([0-9a-f-]+)")
    text.gsub(pattern) do |match|
      type = $1
      id = $2
      model = models[type]
      column_name = id.length == 8 ? :truncated_id : :id
      record = model.find_by(column_name => id)
      if record
        yield record
      end
    end
  end

  def initialize(from_record: nil, subdomain: nil)
    @from_record = from_record
    @subdomain = subdomain
    if @from_record.nil? && @subdomain.nil?
      raise ArgumentError, "Must pass in either from_record or subdomain"
    elsif @from_record && @subdomain
      raise ArgumentError, "Cannot pass in both from_record and subdomain"
    end
  end

  def parse(text = nil)
    if @from_record
      if text
        raise ArgumentError, "Cannot pass in text with from_record"
      end
      text = @from_record.class == Note ? @from_record.text : @from_record.description
      subdomain = @from_record.tenant.subdomain
      self.class.parse(text, subdomain: subdomain) do |to_record|
        yield to_record
      end
    elsif @subdomain
      if text.nil?
        raise ArgumentError, "Cannot pass in subdomain without text"
      end
      self.class.parse(text, subdomain: @subdomain) do |to_record|
        yield to_record
      end
    else
      raise ArgumentError, "Cannot parse without text or from_record"
    end
  end

  def parse_and_create_link_records!
    unless @from_record
      raise ArgumentError, "Cannot create link records without a from_record"
    end
    existing_links = Link.where(from_linkable: @from_record)
    # Create hash of existing links by to_record_id
    existing_links_by_to_linkable_id = existing_links.index_by(&:to_linkable_id)
    self.parse do |to_record|
      existing_link = existing_links_by_to_linkable_id[to_record.id]
      if existing_link
        existing_links_by_to_linkable_id.delete(to_record.id)
      else
        Link.create!(from_linkable: @from_record, to_linkable: to_record)
      end
    end
    # Links that are no longer in the text should be destroyed
    existing_links_by_to_linkable_id.values.each(&:destroy)
  end
end