module Api::V1
  class UsersController < BaseController    
    def whoami
      render json: {
        id: current_user.id,
        email: current_user.email,
        username: current_user.username,
        display_name: current_user.display_name,
        created_at: current_user.created_at,
        updated_at: current_user.updated_at,
      }
    end
  end
end
