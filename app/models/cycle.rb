class Cycle
  attr_accessor :name

  def self.end_of_cycle_options(tempo:)
    full_list = [
      'end of day today',
      'end of day tomorrow',
      'end of this week',
      'end of next week',
      'end of this month',
      'end of next month',
      'end of this year',
      'end of next year',
    ]
    case tempo
    when 'daily'
      full_list
    when 'weekly'
      full_list - ['end of day today', 'end of day tomorrow']
    when 'monthly'
      full_list - ['end of day today', 'end of day tomorrow', 'end of this week', 'end of next week']
    else
      raise 'Invalid tempo'
    end
  end

  def self.new_from_end_of_cycle_option(end_of_cycle:, tenant:, studio:)
    cycle = end_of_cycle.downcase.gsub(' ', '-').split(/end-of-(?:day-)?/).last
    new(name: cycle, tenant: tenant, studio: studio)
  end

  def self.new_from_tempo(tenant:, studio:)
    case studio.tempo
    when 'daily'
      new(name: 'today', tenant: tenant, studio: studio)
    when 'weekly'
      new(name: 'this-week', tenant: tenant, studio: studio)
    when 'monthly'
      new(name: 'this-month', tenant: tenant, studio: studio)
    when 'yearly'
      new(name: 'this-year', tenant: tenant, studio: studio)
    else
      raise 'Invalid tempo'
    end
  end

  def initialize(name:, tenant:, studio:, params: {}, current_user: nil)
    @name = name
    @tenant = tenant
    @studio = studio
    @params = params || {}
    @current_user = current_user
    raise "Invalid tenant" if @tenant.nil?
    raise "Invalid studio" if @studio.nil?
  end

  def api_json(include: [])
    response = {
      name: name,
      display_name: display_name,
      time_window: display_window,
      unit: unit,
      start_date: start_date,
      end_date: end_date,
      counts: counts,
    }
    if include.include?('notes')
      response.merge!({ notes: notes.map(&:api_json) })
    end
    if include.include?('decisions')
      response.merge!({ decisions: decisions.map(&:api_json) })
    end
    if include.include?('commitments')
      response.merge!({ commitments: commitments.map(&:api_json) })
    end
    if include.include?('backlinks')
      response.merge!({ backlinks: backlinks.map(&:api_json) })
    end
    response
  end

  def display_name
    @name.titleize
  end

  def path
    "#{@studio.path}/cycles/#{@name}"
  end

  def path_with_params
    p = {}
    if params[:filters].present? && params[:filters] != 'none'
      p[:filters] = params[:filters]
    end
    if params[:sort_by].present?
      p[:sort_by] = params[:sort_by]
    end
    if p.empty?
      path
    else
      "#{path}?#{p.to_query}"
    end
  end

  def display_window
    case unit
    when 'day'
      start_date.strftime('%A, %B %e, %Y')
    when 'week'
      "#{start_date.strftime('%B %e')} - #{end_date.strftime('%B %e, %Y')}"
    when 'month'
      start_date.strftime('%B %Y')
    when 'year'
      start_date.strftime('%Y')
    when 'custom'
      "#{start_date.strftime('%B %e')} - #{end_date.strftime('%B %e, %Y')}"
    end
  end

  def display_duration
    case unit
    when 'day'
      '1 day'
    when 'week'
      '1 week'
    when 'month'
      '1 month'
    when 'year'
      '1 year'
    when 'custom'
      # Largest unit first, e.g. 1 year, 2 months, 3 days
      duration = []
      duration << "#{(end_date - start_date).to_i / 365} year(s)" if (end_date - start_date).to_i >= 365
      duration << "#{(end_date - start_date).to_i % 365 / 30} month(s)" if (end_date - start_date).to_i % 365 >= 30
      duration << "#{(end_date - start_date).to_i % 30} day(s)" if (end_date - start_date).to_i % 30 > 0
      duration.join(', ')
    end
  end

  def id
    "Cycles > #{display_name}"
  end

  def truncated_id
    id
  end

  def unit
    return @unit if defined?(@unit)
    @unit = case @name
    when 'today'
      'day'
    when 'yesterday'
      'day'
    when 'tomorrow'
      'day'
    when 'this-week'
      'week'
    when 'last-week'
      'week'
    when 'next-week'
      'week'
    when 'this-month'
      'month'
    when 'last-month'
      'month'
    when 'next-month'
      'month'
    when 'this-year'
      'year'
    when 'last-year'
      'year'
    when 'next-year'
      'year'
    else
      # TODO hand year, month, week, day
      # e.g. 2020, 2020-01, 2020-week-1, 2020-01-01
    end
  end

  def unit_for_custom_date
    return @unit_for_custom_date if defined?(@unit_for_custom_date)
    is_month_name = [
      'january', 'february', 'march',
      'april', 'may', 'june', 'july',
      'august', 'september', 'october',
      'november', 'december'
    ].include?(@name)
    @unit_for_custom_date = is_month_name ? 'month' : 'day'
  end

  def now
    Time.current.in_time_zone(@studio.timezone.name)
  end

  def start_date
    return @start_date if defined?(@start_date)
    if @name.starts_with?('last-') || @name == 'yesterday'
      relative_now = now - 1.send(unit)
    elsif @name.starts_with?('next-') || @name == 'tomorrow'
      relative_now = now + 1.send(unit)
    else
      relative_now = now
    end
    # @start_date = relative_now.in_time_zone(timezone).send("beginning_of_#{unit}")
    @start_date = relative_now.send("beginning_of_#{unit}")
  end

  def end_date
    return @end_date if defined?(@end_date)
    # @end_date = start_date.in_time_zone(timezone).send("end_of_#{unit}")
    @end_date = start_date + 1.send(unit)
  end

  def window
    start_date..end_date
  end

  def resources(model)
    # What if updated_at is after deadline?
    rs = model.where(tenant_id: @tenant.id, studio_id: @studio.id)
              .where('created_at < ?', end_date)
              .where('deadline > ?', start_date)
    if filters.present?
      filters.each do |filter|
        rs = rs.where(filter)
      end
    end
    rs.order(sort_by)
  end

  def params
    @params
  end

  def sort_by_options
    [
      ['Deadline (earliest first)', 'deadline-asc'],
      ['Deadline (latest first)', 'deadline-desc'],
      ['Created (oldest first)', 'created_at-asc'],
      ['Created (newest first)', 'created_at-desc'],
      ['Updated (oldest first)', 'updated_at-asc'],
      ['Updated (most recent first)', 'updated_at-desc'],
    ]
  end

  def sort_by
    return @sort_by if @sort_by
    key, direction = (params[:sort_by] || 'deadline:desc').split('-')
    key = 'deadline' unless %w[created_at updated_at deadline].include?(key)
    direction = 'desc' unless %w[asc desc].include?(direction)
    @sort_by = { key => direction }
  end

  def filter_options
    dn = display_name.downcase
    past_cycle = end_date < now
    future_cycle = start_date > now
    current_cycle = start_date <= now && end_date >= now
    [
      ["None", 'none'],
      # Created
      ["Created by me", 'mine'],
      (past_cycle || current_cycle) ? ["Created #{dn}", 'new'] : nil,
      (past_cycle || current_cycle) ? ["Created before #{dn}", 'old'] : nil,
      # Open
      past_cycle ? ["Still open", 'open'] : nil,
      current_cycle ? ["Open", 'open'] : nil,
      current_cycle ? ["Open currently, closing #{dn}", 'closing_soon'] : nil,
      # Closed
      (past_cycle || current_cycle) ? ["Closed", 'closed'] : nil,
      current_cycle ? ["Closed or closing #{dn}", 'deadline_within_cycle'] : nil,
      past_cycle ? ["Closed #{dn}", 'deadline_within_cycle'] : nil,
      future_cycle ? ["Closing #{dn}", 'deadline_within_cycle'] : nil,
      (current_cycle || future_cycle) ? ["Closing after #{dn}", 'deadline_after_cycle'] : nil,
      # Updated
      ["Updated", 'updated'],
      (past_cycle || current_cycle) ? ["Updated #{dn}", 'updated_within_cycle'] : nil,
      (past_cycle || current_cycle) ? ["Created or updated #{dn}", 'created_or_updated_within_cycle'] : nil,
    ].compact
  end

  def filters
    return @filters if defined?(@filters)
    return @filters = nil unless params[:filters].present?
    valid_keys = %w[created_by created_at updated_at deadline] + filter_options.map(&:last)
    @filters = params[:filters].split(',').map do |filter|
      key, value = filter.split(':')
      next if key == 'none'
      if value.nil?
        key, gt = key.split('>')
        key, lt = key.split('<') if gt.nil?
        next unless valid_keys.include?(key)
        if gt
          ["#{key} > ?", gt]
        elsif lt
          ["#{key} < ?", lt]
        elsif key == 'mine'
          ['created_by_id = ?', @current_user.id]
        elsif key == 'open'
          ['deadline > ?', Time.current]
        elsif key == 'closed'
          ['deadline < ?', Time.current]
        elsif key == 'closing_soon'
          ['deadline > ? and deadline < ?', Time.current, self.end_date]
        elsif key == 'deadline_within_cycle'
          ['deadline > ? and deadline < ?', self.start_date, self.end_date]
        elsif key == 'deadline_after_cycle'
          ['deadline > ?', self.end_date]
        elsif key == 'new'
          ['created_at > ?', self.start_date]
        elsif key == 'old'
          ['created_at < ?', self.start_date]
        elsif key == 'updated'
          ['updated_at != created_at']
        elsif key == 'updated_within_cycle'
          ['updated_at > ? and updated_at != created_at', self.start_date]
        elsif key == 'created_or_updated_within_cycle'
          ['created_at > ? or updated_at > ?', self.start_date, self.start_date]
        else
          raise "Invalid filter: #{key}"
        end
      elsif key == 'created_by'
        u = User.find_by(handle: value)
        u ? ['created_by_id = ?', u.id] : nil
      else
        next unless valid_keys.include?(key)
        ["#{key} = ?", value]
      end
    end.compact
  end

  def notes
    @notes ||= resources(Note)
  end

  def decisions
    @decisions ||= resources(Decision)
  end

  def commitments
    @commitments ||= resources(Commitment)
  end

  def counts
    # TODO - make this more efficient for homepage query. Ideally in one query.
    @counts ||= {
      notes: notes.count,
      decisions: decisions.count,
      commitments: commitments.count,
    }
  end

  def total_count
    counts.values.sum
  end

  def backlinks
    # Link.backlink_leaderboard(start_date: start_date, end_date: end_date, tenant_id: @tenant.id)
    Link.where(tenant: @tenant, studio: @studio)
        .where(from_linkable: [notes, decisions, commitments].flatten)
        .includes(:to_linkable)
        .map(&:to_linkable).uniq
  end

end