module Api::V1
  class UsersController < BaseController
    def index
      render json: current_tenant.team.map(&:api_json)
    end

    def show
      user = current_tenant.users.find_by(id: params[:id])
      return render json: { error: 'User not found' }, status: 404 unless user
      render json: user.api_json
    end

    def create
      # Only simulated users can be created via the API
      ActiveRecord::Base.transaction do
        user = User.create!(
          name: params[:name],
          email: SecureRandom.uuid + '@not-a-real-email.com',
          simulated: true,
          parent_id: current_user.id,
        )
        tenant_user = TenantUser.create!(
          user: user,
          tenant: current_tenant,
          display_name: params[:name],
          handle: params[:handle],
        )
        user.tenant_user = tenant_user
        token = generate_token(user) if params[:generate_token]
        response = user.api_json
        response[:token] = token.token if token
        render json: response
      rescue ActiveRecord::RecordInvalid => e
        # TODO - Detect specific validation errors and return helpful error messages
        render json: { error: 'There was an error creating the user. Please try again.' }, status: 400
      end
    end

    def update
      # Users can only update their own records or simulated users
      user = current_tenant.users.find_by(id: params[:id])
      return render json: { error: 'User not found' }, status: 404 unless user
      return render json: { error: 'Unauthorized' }, status: 401 unless current_user.can_edit?(user)
      updatable_attributes.each do |attribute|
        user[attribute] = params[attribute] if params.has_key?(attribute)
      end
      if params[:archived] == true && current_user != user
        user.archive!
      elsif params[:archived] == false && current_user != user
        user.unarchive!
      end
      if user.changed?
        user.save!
      end
      render json: user.api_json
    end

    def destroy
      # Users can only delete simulated users with no associated data
      user = current_tenant.users.find_by(id: params[:id])
      return render json: { error: 'User not found' }, status: 404 unless user
      return render json: { error: 'Unauthorized' }, status: 401 unless current_user.can_edit?(user)
      ActiveRecord::Base.transaction do
        user.tenant_user.destroy!
        ApiToken.where(user: user).destroy_all
        user.destroy!
        render json: { message: 'User deleted' }
      rescue ActiveRecord::InvalidForeignKey => e
        render json: { error: 'This user has associated data and cannot be deleted, but you can archive this user via PUT /api/v1/users/:user_id { "archived": true }' }, status: 400
      end
    end

    private

    def updatable_attributes
      # Cannot update email because we derive from oauth provider
      [:display_name, :handle] # How to update pins?
    end

    def generate_token(user)
      ApiToken.create!(
        name: "#{user.display_name}'s API Token",
        user: user,
        expires_at: 1.year.from_now,
        scopes: ApiToken.read_scopes + ApiToken.write_scopes,
      )
    end
  end
end
