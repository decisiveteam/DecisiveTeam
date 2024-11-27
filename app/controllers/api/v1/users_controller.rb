module Api::V1
  class UsersController < BaseController
    def index
      render json: current_tenant.team.map(&:api_json)
    end

    def create
      render_404
      ## TODO
      # ActiveRecord::Base.transaction do
      #   user = User.create!(
      #     name: params[:name],
      #   )
      #   tenant_user = TenantUser.create!(
      #     user: user,
      #     tenant: current_tenant,
      #     display_name: params[:name],
      #     handle: params[:handle],
      #   )
      #   user.tenant_user = tenant_user
      #   render json: user.api_json
      # rescue ActiveRecord::RecordInvalid => e
      #   # TODO - Detect specific validation errors and return helpful error messages
      #   render json: { error: 'There was an error creating the user. Please try again.' }, status: 400
      # end
    end

    def update
      # Users can only update their own records (until we add simulated users)
      user = current_tenant.users.find_by(id: params[:id])
      return render json: { error: 'User not found' }, status: 404 unless user
      return render json: { error: 'Unauthorized' }, status: 401 unless user == current_user
      updatable_attributes.each do |attribute|
        user[attribute] = params[attribute] if params.has_key?(attribute)
      end
      if user.changed?
        user.save!
      end
      render json: user.api_json
    end

    private

    def updatable_attributes
      # Cannot update email because we derive from oauth provider
      [:display_name, :handle] # How to update pins?
    end
  end
end
