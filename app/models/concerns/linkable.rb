module Linkable
  extend ActiveSupport::Concern

  included do
    has_many :links, as: :from_linkable, dependent: :destroy
    has_many :links, as: :to_linkable, dependent: :destroy
    after_save :parse_and_create_link_records!
  end

  def parse_and_create_link_records!
    LinkParser.new(from_record: self).parse_and_create_link_records!
  end

  def backlinks
    Link.where(to_linkable: self).order(updated_at: :desc).map(&:from_linkable)
  end

  class_methods do
    def is_linkable?
      true
    end
  end
end
