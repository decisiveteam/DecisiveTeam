class TeamInvite < ApplicationRecord
  belongs_to :team
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  
  before_create :generate_code

  def self.find_by_code(code)
    self.find_by(code: code)
  end

  def generate_code
    self.code ||= SecureRandom.hex(16)
  end

  def use!
    self.uses += 1
    save!
  end

  def expired?
    DateTime.now > expires_at
  end

  def remaining_uses
    max_uses - uses
  end

  def used_up?
    remaining_uses <= 0
  end

  def assert_valid!
    raise 'Invite code is expired' if expired?
    raise 'Invite code has been used too many times' if used_up?
  end

  def shareable_link
    protocol = ENV['HOSTNAME'].include?('localhost') ? 'http' : 'https'
    "#{protocol}://#{ENV['HOSTNAME']}/teams/#{team.id}/join/#{code}"
  end

  def confirmation_link
    protocol = ENV['HOSTNAME'].include?('localhost') ? 'http' : 'https'
    "#{protocol}://#{ENV['HOSTNAME']}/teams/#{team.id}/join/#{code}/confirm"
  end
end