class DevicePoolsController < ApplicationController
  load_and_authorize_resource
  
  def new; end
  
  def create
    @device_pool.provider = current_provider
    if @device_pool.save
      flash[:notice] = "Device pool created"
      redirect_to provider_path(current_provider)
    else
      render :action=>:new
    end
  end
  
  def edit; end
  
  def update
    @device_pool.update_attributes(params[:device_pool])
    if @device_pool.save
      flash[:notice] = "Device pool updated"
      redirect_to provider_path(current_user.current_provider)
    else
      render :action=>:edit
    end
  end
end
