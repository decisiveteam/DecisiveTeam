# This class handles logic related to the system resources created in seeds.rb
# These include the system user, system team, and system oauth application
class SystemResourceService
  def self.system_user
    @system_user ||= User.find_by(email: "system@decisive.team")
    raise "System user not found" if @system_user.nil?
    @system_user
  end

  def self.system_team
    @system_team ||= Team.find_by(name: "System", handle: "system")
    raise "System team not found" if @system_team.nil?
    @system_team
  end

  def self.system_oauth_application
    @system_oauth_application ||= Doorkeeper::Application.find_by(
      uid: "system", name: "System", owner: system_user
    )
    raise "System oauth application not found" if @system_oauth_application.nil?
    @system_oauth_application
  end

  def self.create_system_resources!
    @system_user = User.find_or_create_by!(email: 'system@decisive.team') do |user|
      # This user acts as the owner of the system OAuth application.
      user.username = 'system'
      user.password = SecureRandom.hex
      user.display_name = 'System'
      user.confirmed_at = Time.now
      user.is_admin = true
    end
    
    @system_team = Team.find_or_create_by!(name: 'System') do |team|
      # This team is intended to consist of system users, such as the system user above,
      # and admin users/developers who manage the system through the admin API.
      team.handle = 'system'
    end
    
    @system_team.users << @system_user unless @system_team.users.include?(@system_user)
    
    @system_oauth_application = Doorkeeper::Application.find_or_create_by!(name: 'System') do |app|
      # This application is used to generate access tokens for individual users
      # so they can access the API without having to go through the OAuth flow.
      app.uid = 'system'
      app.owner = @system_user
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      app.scopes = 'read write'
    end    
  end
end