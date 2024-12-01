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
    @cycle = Cycle.new(name: params[:cycle], tenant: @current_tenant, studio: @current_studio)
    @current_resource = @cycle
    @notes = @cycle.notes
    @decisions = @cycle.decisions
    @commitments = @cycle.commitments
    @backlinks = @cycle.backlinks
  end

end