class TeamInvite < InviteRecord
  has_many :team_members

  def shareable_link
    protocol = ENV['HOSTNAME'].include?('localhost') ? 'http' : 'https'
    "#{protocol}://#{ENV['HOSTNAME']}/teams/#{team.id}/join/#{code}"
  end

  def confirmation_link
    protocol = ENV['HOSTNAME'].include?('localhost') ? 'http' : 'https'
    "#{protocol}://#{ENV['HOSTNAME']}/teams/#{team.id}/join/#{code}/confirm"
  end
end