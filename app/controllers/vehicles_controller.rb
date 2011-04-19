class VehiclesController < ApplicationController
  load_and_authorize_resource

  def new
  end

  def show

  end

  def index
    redirect_to provider_path(current_provider)
  end

  def edit
  end

  def update
    params[:vehicle][:provider_id] = current_provider
    if @vehicle.update_attributes(params[:vehicle])
      flash[:notice] = "Vehicle updated"
      redirect_to provider_path(current_provider)
    else
      render :action=>:edit
    end 
  end

  def create
    @vehicle.provider = current_provider
    if @vehicle.save
      flash[:notice] = "Vehicle created"
      redirect_to provider_path(current_provider)
    else
      render :action=>:new
    end
  end

end
