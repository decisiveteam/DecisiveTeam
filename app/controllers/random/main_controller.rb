class Random::MainController < Random::BaseRandomController
  def index
    render json: { message: 'Hello, world!' }
  end

  def new
  end

  def beacon
    seed = params[:seed]
    return render json: { error: 'seed parameter is required for the beacon endpoint' }, status: 400 unless seed
    time_unit = params[:time_unit]
    unless %w[second minute hour day week month year].include?(time_unit)
      message = "Invalid time unit: #{time_unit}. Must be one of: second minute, hour, day, week, month, year"
      return render json: { error: message }, status: 400
    end
    timestamp = Time.current.to_s.to_time
    time_point = params[:time_point].to_time if params[:time_point]
    time_point ||= timestamp
    unless time_point <= Time.current
      return render json: { error: 'time_point cannot be in the future' }, status: 400
    end
    if time_unit == 'second'
      time_window_start = time_point.change(usec: 0)
      time_window_end = time_point.change(usec: 999_999)
    else
      time_window_start = time_point.send("beginning_of_#{time_unit}")
      time_window_end = time_point.send("end_of_#{time_unit}")
    end
    if params[:list]
      list = params[:list].is_a?(Array) ? params[:list] : params[:list].split(',')
      shuffled_list = shuffle(seed, list)
      value = shuffled_list
    else
      list = nil
      hash = hash_with_secret([seed, time_window_start.to_s, time_window_end.to_s])
      value = Random.new(hash.to_i(16)).rand.to_s
    end
    @json_response = {
      input: {
        time_point: time_point,
        time_unit: time_unit,
        seed: seed,
        list: list,
      },
      output: {
        time_window_start: time_window_start,
        time_window_end: time_window_end,
        value: value,
      },
      timestamp: timestamp,
      message: 'This random value is intended for group coordination purposes only, and not for cryptographic purposes. Do not use this endpoint for security-sensitive applications.',
    }
    respond_to do |format|
      format.json do
        render json: @json_response
      end
      format.html do
        render layout: 'application'
      end
    end
  end

  def cointoss
    seed = params[:seed] || SecureRandom.hex(16)
    render json: {
      input: {
        seed: seed,
      },
      output: {
        result: shuffle(seed, %w[heads tails]).first,
      },
      timestamp: Time.current,
    }
  end

  def shuffle_items
    items = params[:items]
    seed = params[:seed] || SecureRandom.hex(16)
    if items.is_a?(String)
      items = items.split(',')
    elsif items.is_a?(Array)
      items = items.map(&:to_s)
    else
      return render json: { error: 'Invalid items parameter' }, status: 400
    end
    if items.size < 2
      message = 'At least two items are required to shuffle. Please provide a comma-separated list of items.'
      return render json: { error: message }, status: 400
    end
    render json: {
      input: {
        items: items,
        seed: seed,
      },
      output: {
        shuffled_items: shuffle(seed, items),
      },
      timestamp: Time.current,
    }
  end

end
