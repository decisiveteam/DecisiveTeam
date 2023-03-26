class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.accessible_by(user)
    raise NotImplementedError, "Must implement self.accessible_by in #{self.name}"
  end
end
