# This class handles logic related to the system resources created in seeds.rb
# These include the system user, system team, and system oauth application
class SystemResourceService
  def self.anonymous_user
    @anonymous_user ||= User.find_by(email: "anonymous@decisive.team")
    raise "Anonymous user not found" if @anonymous_user.nil?
    @anonymous_user
  end

  def self.anonymous_team
    @anonymous_team ||= Team.find_by(name: "Anonymous", handle: "anonymous")
    raise "anonymous team not found" if @anonymous_team.nil?
    @anonymous_team
  end

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

  def self.create_anonymous_resources!
    @anonymous_user = User.find_or_create_by!(email: 'anonymous@decisive.team') do |user|
      # This user is used to represent anonymous users in the system.
      user.username = 'anonymous'
      user.password = SecureRandom.hex
      user.display_name = 'Anonymous'
      user.confirmed_at = Time.now
    end
    
    # NOTE - Even if the anonymous team is disabled, we still want to claim the handle.
    @anonymous_team = Team.find_or_create_by!(handle: 'anonymous') do |team|
      # This team is completely public and does not require authentication to access.
      team.name = 'Anonymous'
    end
    
    @anonymous_team.users << @anonymous_user unless @anonymous_team.users.include?(@anonymous_user)
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

    @system_team = Team.find_or_create_by!(handle: 'system') do |team|
      # This team is intended to consist of system users, such as the system user above,
      # and admin users/developers who manage the system through the admin API.
      team.name = 'System'
    end
    
    @system_team.users << @system_user unless @system_team.users.include?(@system_user)
    
    @system_oauth_application = Doorkeeper::Application.find_or_create_by!(uid: 'system') do |app|
      # This application is used to generate access tokens for individual users
      # so they can access the API without having to go through the OAuth flow.
      app.name = 'System'
      app.owner = @system_user
      app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      app.scopes = 'read write'
    end

    @public_team = Team.find_or_create_by!(handle: 'public') do |team|
      # This team is the default team for all users. Anyone can join this team and make decisions.
      team.name = 'Public'
    end
  end
end