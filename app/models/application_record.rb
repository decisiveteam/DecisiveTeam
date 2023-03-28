class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.accessible_by(user)
    self.where(team: user.teams)
  end

  def self.is_tracked?
    false
  end

  def is_tracked?
    self.class.is_tracked?
  end
end
