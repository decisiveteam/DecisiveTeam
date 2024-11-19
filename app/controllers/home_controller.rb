class HomeController < ApplicationController

  def index
    @page_title = @current_tenant.name
  end

end
