class V1::DevicePoolDriversController < ApplicationController
  include ::SslRequirement

  skip_before_filter :authenticate_user! # temporary
  ssl_required :update, :index
  
  # POST /v1/device_pool_drivers/1.json
  # options:  device_pool_driver[status]=active|inactive|break 
  #           device_pool_driver[lat]=40.689060
  #           device_pool_driver[lng]=-74.044636
  # returns:  { id : 1, lat : 40.689060, lng : -74.044636, status : "active" }
  
  def update
    respond_to do |format|
      format.json do
        device_pool_driver = begin
          DevicePoolDriver.find params[:id]
        rescue ActiveRecord::RecordNotFound => rnf
          return render :json => { :error => rnf.message }, :status => 404
        end
        
        if device_pool_driver.update_attributes( params[:device_pool_driver] )
          render :json => { :device_pool_driver => device_pool_driver.as_mobile_json }, :status => 200
        else
          render :json => { :error => device_pool_driver.errors }, :status => 400
        end
      end
    end
  rescue Exception => e
    render :json => { :error => e.message }, :status => 500
  end
  
end
