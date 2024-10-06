class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.is_tracked?
    false
  end

  def is_tracked?
    self.class.is_tracked?
  end

  def deadline_iso8601
    if deadline
      deadline.iso8601
    else
      ""
    end
  end

  def closed?
    deadline && deadline < Time.now
  end

  def path
    "/#{path_prefix}/#{self.truncated_id}"
  end

  def shareable_link
    "https://#{ENV['HOSTNAME']}#{path}"
  end
end
