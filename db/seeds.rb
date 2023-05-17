system_user = User.find_or_create_by!(email: 'system@decisive.team') do |user|
  # This user acts as the owner of the system OAuth application.
  user.username = 'system'
  user.password = SecureRandom.hex
  user.display_name = 'System'
  user.confirmed_at = Time.now
  user.is_admin = true
end

system_team = Team.find_or_create_by!(name: 'System') do |team|
  # This team is intended to consist of system users, such as the system user above,
  # and admin users/developers who manage the system through the (future) admin API.
  team.handle = 'system'
end

system_team.users << system_user unless system_team.users.include?(system_user)

system_oauth_application = Doorkeeper::Application.find_or_create_by!(name: 'System') do |app|
  # This application is used to generate access tokens for individual users
  # so they can access the API without having to go through the OAuth flow.
  app.owner = system_user
  app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
  app.scopes = 'read write'
end
