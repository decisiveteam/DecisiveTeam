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
    @filter = params[:filter] || 'all'
    @group_by = params[:group_by] || 'type'
    @sort_by = params[:sort_by] || 'created_at:desc'
    @cycle = Cycle.new(name: params[:cycle], tenant: @current_tenant, studio: @current_studio)
    @current_resource = @cycle
    # @view = @cycle.view(
    #   filter: @filter,
    #   group_by: @group_by,
    #   sort_by: @sort_by,
    # )
    @notes = @cycle.notes
    @decisions = @cycle.decisions
    @commitments = @cycle.commitments
    @backlinks = @cycle.backlinks
  end

end