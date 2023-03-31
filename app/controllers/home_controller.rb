class HomeController < ApplicationController
  def index
    @message = if current_user
                "# Hello #{current_user.email}\\n" +
                "key: val\\n"
              else
                'Hello World!'
              end
    # render json: { message: message }
  end
end
