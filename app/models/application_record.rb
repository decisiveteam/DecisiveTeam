class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.accessible_by(user)
    self.where(team: user.teams)
  end
end
