class DataDeletionManager
  def initialize(resource:, user:, dry_run: false)
    @resource = resource
    @user = user
    # Dry run creates a list of items that will be deleted, but does not delete them
    @dry_run = dry_run
  end

  def delete!
    case @resource.class
    when User
      delete_user!
    when Studio
      delete_studio!
    when Tenant
      delete_tenant!
    when Note
      delete_note!
    when Decision
      delete_decision!
    when Commitment
      delete_commitment!
    else
      raise "Unsupported resource class: #{resource.class}"
    end
  end
end