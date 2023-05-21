class DecisionInvite < InviteRecord
  belongs_to :decision
  has_many :decision_participants

  # TODO - implement this in routes, etc.
  # def shareable_link
  #   protocol = ENV['HOSTNAME'].include?('localhost') ? 'http' : 'https'
  #   "#{protocol}://#{ENV['HOSTNAME']}/decisions/#{decision.id}/participate/#{code}"
  # end

  # def confirmation_link
  #   protocol = ENV['HOSTNAME'].include?('localhost') ? 'http' : 'https'
  #   "#{protocol}://#{ENV['HOSTNAME']}/decisions/#{decision.id}/participate/#{code}/confirm"
  # end
end