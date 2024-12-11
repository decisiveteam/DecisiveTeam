class RandomBeacon
  attr_accessor :seed, :time_point, :time_unit, :list

  def self.valid_time_units
    %w[second minute hour day week month year]
  end

  def self.validate_time_unit(time_unit)
    unless self.valid_time_units.include?(time_unit)
      raise "Invalid time unit: #{time_unit}. Must be one of: #{self.valid_time_units.join(', ')}"
    end
  end

  def initialize(seed: nil, time_point: nil, time_unit: nil, list: nil, output_type: nil)
    @seed = seed
    if time_point > Time.current
      raise 'time_point cannot be in the future'
    end
    @time_point = time_point
    self.class.validate_time_unit(time_unit)
    @time_unit = time_unit
    @list = list
  end
end