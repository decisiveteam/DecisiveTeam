class CyclesController < ApplicationController

  def index
    # TODO - Make these queries more efficient
    @current_cycles = [
      Cycle.new(name: 'today', tenant_id: @current_tenant.id),
      Cycle.new(name: 'this-week', tenant_id: @current_tenant.id),
      Cycle.new(name: 'this-month', tenant_id: @current_tenant.id),
      Cycle.new(name: 'this-year', tenant_id: @current_tenant.id),
    ]
    @recent_cycles = [
      Cycle.new(name: 'yesterday', tenant_id: @current_tenant.id),
      Cycle.new(name: 'last-week', tenant_id: @current_tenant.id),
      Cycle.new(name: 'last-month', tenant_id: @current_tenant.id),
      Cycle.new(name: 'last-year', tenant_id: @current_tenant.id),
    ]
    @future_cycles = [
      Cycle.new(name: 'tomorrow', tenant_id: @current_tenant.id),
      Cycle.new(name: 'next-week', tenant_id: @current_tenant.id),
      Cycle.new(name: 'next-month', tenant_id: @current_tenant.id),
      Cycle.new(name: 'next-year', tenant_id: @current_tenant.id),
    ]
  end

  def show
    @cycle = Cycle.new(name: params[:cycle], tenant_id: @current_tenant.id)
    @current_resource = @cycle
    @notes = @cycle.notes
    @decisions = @cycle.decisions
    @commitments = @cycle.commitments
    @backlinks = @cycle.backlinks
  end

end