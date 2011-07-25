class V1::DevicesController < ApplicationController
  skip_before_filter :authenticate_user!
  
  # POST /v1/devices ? android_id=ANDROID_ID 
  # registers device
  def create
    device = Device.new :android_id => params[:android_id], :name => params[:name]
    
    if device.save
      render :json => { :device => { :id => id } }, :status => 201
    else
      render :json => { :errors => [device.errors.to_json] }, :status => 400
    end
  end
  
  # POST /v1/devices/ANDROID_ID ? _method=PUT status=STATUS | lat=LAT | lng=LNG | driver_id=driver
  # update status and/or position and/or driver (driver ID returned after authentication)
  def update
    if params[:id].blank? || (device = Device.where(:android_id => params[:id]).first).blank?
      render :json => { :errors => ["ANDROID_ID is required"]}, :status => 404
    elsif device.update_attributes( params[:device] )
      render :json => { :device => device.as_json }, :status => 200
    else
      
    end 
  end
  
end
