class Reference < ApplicationRecord
  belongs_to :referencer, polymorphic: true
  belongs_to :referenced, polymorphic: true
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
end
