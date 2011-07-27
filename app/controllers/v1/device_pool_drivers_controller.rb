class V1::DevicePoolDriversController < ApplicationController
  skip_before_filter :authenticate_user! # temporary
  
  # POST /v1/device_pool_drivers/:id.json ? device_pool_driver[status]=STATUS | device_pool_driver[lat]=LAT | device_pool_driver[lng]=LNG
  def update
    respond_to do |format|
      format.json do
        device_pool_driver = begin
          DevicePoolDriver.find params[:id]
        rescue ActiveRecord::RecordNotFound => rnf
          return render :json => { :error => rnf.message }, :status => 404
        rescue Exception => e
          return render :json => { :error => e.message }, :status => 500
        end
        
        if device_pool_driver.update_attributes( params[:device_pool_driver] )
          render :json => { :device_pool_driver => device_pool_driver.as_json }, :status => 200
        else
          render :json => { :error => device_pool_driver.errors }, :status => 400
        end
      end
    end
  rescue Exception => e
    render :json => { :error => e.message }, :status => 500
  end
  
end
