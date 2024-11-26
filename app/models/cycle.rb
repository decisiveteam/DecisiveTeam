class Cycle
  attr_accessor :name

  def initialize(name:, tenant_id:)
    @name = name
    @tenant_id = tenant_id
    raise "Invalid tenant_id" if @tenant_id.nil?
  end

  def display_name
    @name.titleize
  end

  def path
    "/cycles/#{@name}"
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

  def start_date
    return @start_date if defined?(@start_date)
    if @name.starts_with?('last-') || @name == 'yesterday'
      relative_now = 1.send(unit).ago
    elsif @name.starts_with?('next-') || @name == 'tomorrow'
      relative_now = 1.send(unit).from_now
    else
      relative_now = Time.current
    end
    @start_date = relative_now.send("beginning_of_#{unit}")
  end

  def end_date
    return @end_date if defined?(@end_date)
    @end_date = start_date.send("end_of_#{unit}")
  end

  def window
    start_date..end_date
  end

  def resources(model)
    model.where(tenant_id: @tenant_id)
         .where('created_at < ?', end_date).where('deadline > ?', start_date)
         .order(deadline: :asc)
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

  def backlinks
    Link.backlink_leaderboard(start_date: start_date, end_date: end_date, tenant_id: @tenant_id)
  end
end