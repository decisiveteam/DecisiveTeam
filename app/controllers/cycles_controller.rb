class CyclesController < ApplicationController

  def index
    # TODO - Make these queries more efficient
    @current_cycles = ['today', 'this-week', 'this-month', 'this-year'].map do |name|
      Cycle.new(name: name, tenant: @current_tenant, studio: @current_studio)
    end
    @recent_cycles = ['yesterday', 'last-week', 'last-month', 'last-year'].map do |name|
      Cycle.new(name: name, tenant: @current_tenant, studio: @current_studio)
    end
    @future_cycles = ['tomorrow', 'next-week', 'next-month', 'next-year'].map do |name|
      Cycle.new(name: name, tenant: @current_tenant, studio: @current_studio)
    end
  end

  def show
    @cycle = Cycle.new(
      name: params[:cycle],
      tenant: @current_tenant,
      studio: @current_studio,
      current_user: @current_user,
      params: {
        filters: params[:filters] || params[:filter],
        sort_by: params[:sort_by],
      }
    )
    @current_resource = @cycle
    @notes = @cycle.notes
    @decisions = @cycle.decisions
    @commitments = @cycle.commitments
    @backlinks = @cycle.backlinks
    @filters = params[:filters] || params[:filter]
    @sort_by = params[:sort_by]
    @sort_by_options = @cycle.sort_by_options
    @filter_options = @cycle.filter_options
  end

  def redirect_to_show
    # If people go to /cycle/... instead of /cycles/...
    redirect_to "#{@current_studio.path}/cycles/#{params[:cycle]}"
  end

end