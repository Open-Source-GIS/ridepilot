class VehicleMaintenanceEventsController < ApplicationController
  load_and_authorize_resource

  def new
    @vehicle_maintenance_event.vehicle_id=params[:vehicle_id]
  end

  def index
    redirect_to provider_path(current_user.current_provider)
  end

  def edit
  end

  def update
    params[:vehicle_maintenance_event][:provider_id] = nil
    if @vehicle_maintenance_event.update_attributes(params[:vehicle_maintenance_event])
      flash[:notice] = "Vehicle maintenance event updated"
      redirect_to vehicle_path(@vehicle_maintenance_event.vehicle)
    else
      render :action=>:edit
    end 
  end

  def create
    @vehicle_maintenance_event.provider = current_user.current_provider
    if @vehicle_maintenance_event.save
      flash[:notice] = "Vehicle maintenance event created"
      redirect_to vehicle_path(@vehicle_maintenance_event.vehicle)
    else
      render :action=>:new
    end
  end

end
