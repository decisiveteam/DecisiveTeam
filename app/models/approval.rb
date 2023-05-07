class Approval < ApplicationRecord
  include Tracked
  belongs_to :option
  belongs_to :decision
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  belongs_to :team

  validates :value, inclusion: { in: [0, 1] }
  validates :stars, inclusion: { in: [0, 1] }
end
