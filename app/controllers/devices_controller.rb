class DevicesController < ApplicationController
  load_and_authorize_resource :device_pool
  load_and_authorize_resource :device, :through => :device_pool
  
  def new; end
  
  def create
    @device.device_pool = @device_pool
    if @device.save
      flash[:notice] = "Device created"
      redirect_to provider_path(current_provider)
    else
      render :action=>:new
    end
  end
  
  def edit; end
  
  def update
    @device.update_attributes(params[:device])
    if @device.save
      flash[:notice] = "Device updated"
      redirect_to provider_path(current_user.current_provider)
    else
      render :action=>:edit
    end
  end
end
