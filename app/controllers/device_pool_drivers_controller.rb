class DevicePoolDriversController < ApplicationController
  load_and_authorize_resource :device_pool
  load_and_authorize_resource :device_pool_driver, :through => :device_pool
  
  def create
    @device_pool_driver = @device_pool.device_pool_drivers.build params[:device_pool_driver]
    
    if @device_pool_driver.save
      render :json => { :row => render_to_string(:partial => "device_pool_driver_row.html", :locals => { :device_pool_driver => @device_pool_driver }) }
    else
      render :json => { :errors => @device_pool_driver.errors }
    end
  end
  
  def destroy
    @device_pool_driver.destroy
    render :json => { :device_pool_driver => @device_pool_driver.as_json }
  end
end
