class HomeController < ApplicationController

  def index
    case @current_app
    when 'decisive'
      redirect_to '/decide'
    when 'coordinated'
      redirect_to '/coordinate'
    else
      raise "Unknown app: #{@current_app}"
    end
  end

end
