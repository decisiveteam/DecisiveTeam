class HomeController < ApplicationController

  def index
    # TODO show recent decisions for current participant ID
    redirect_to '/decide'
  end

end
