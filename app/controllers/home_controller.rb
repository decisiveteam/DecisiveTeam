class HomeController < ApplicationController
  def index
    message = if current_user
                "Hello #{current_user.email}"
              else
                'Hello World!'
              end
    render json: { message: message }
  end
end
