class RepresentationSession < ApplicationRecord
  belongs_to :tenant
  belongs_to :studio
  belongs_to :representative_user, class_name: 'User'
  belongs_to :trustee_user, class_name: 'User'

  validates :began_at, presence: true
  validates :confirmed_understanding, inclusion: { in: [true] }

  def api_json
    {
      id: id,
      confirmed_understanding: confirmed_understanding,
      began_at: began_at,
      ended_at: ended_at,
      elapsed_time: elapsed_time,
      activity_log: activity_log,
      studio_id: studio_id,
      representative_user_id: representative_user_id,
      trustee_user_id: trustee_user_id,
    }
  end

  def begin!
    # TODO - add a check for active representation session
    raise 'Must confirm understanding' unless confirmed_understanding
    # TODO - add more validations
    if began_at.nil?
      self.began_at = Time.current
      save!
    end
  end

  def active?
    ended_at.nil?
  end

  def elapsed_time
    return ended_at - began_at if ended_at
    return Time.current - began_at
  end

  def end!
    return if ended?
    self.ended_at = Time.current
    save!
  end

  def ended?
    ended_at.present?
  end

  def expired?
    return ended? || Time.current > began_at + 24.hours
  end

  def record_activity!(request:)
    raise 'Session has ended' if ended?
    raise 'Session has expired' if expired?
    return if request.method == 'GET'
    activity_log['activity'] ||= []
    activity_log['activity'] << {
      happened_at: Time.current,
      activity_type: 'request',
      request: {
        method: request.method,
        path: request.path,
        # Only include the user generated params, not system generated params
        params: request.filtered_parameters,
      }
    }
    save!
  end

  def path
    "/s/#{studio.handle}/representation-sessions/#{id}"
  end

  def url
    "#{tenant.url}#{path}"
  end

end