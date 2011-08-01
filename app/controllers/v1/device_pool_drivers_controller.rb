class V1::DevicePoolDriversController < ApplicationController
  include ::SslRequirement
  ssl_required :update, :index

  skip_before_filter :authenticate_user!
  
  before_filter :authenticate_driver!
  before_filter :authorize_device_pool_driver_for_user!
  
  # POST /v1/device_pool_drivers/1.json
  # options:  device_pool_driver[status]=active|inactive|break 
  #           device_pool_driver[lat]=40.689060
  #           device_pool_driver[lng]=-74.044636
  # requires: user[email]=jmaki@openpizza.org 
  #           user[password]=password
  # returns:  { id : 1, lat : 40.689060, lng : -74.044636, status : "active" }
  def update
    respond_to do |format|
      format.json do
        device_pool_driver = DevicePoolDriver.find params[:id]
        
        if device_pool_driver.update_attributes( params[:device_pool_driver] )
          render :json => { :device_pool_driver => device_pool_driver.as_mobile_json }, :status => 200
        else
          render :json => { :error => device_pool_driver.errors }, :status => 400
        end
      end
    end
  rescue ActiveRecord::RecordNotFound => rnf
    return render :json => { :error => rnf.message }, :status => 404
  rescue Exception => e
    render :json => { :error => e.message }, :status => 500
  end
  
  # POST /device_pool_drivers.json
  # requires: user[email]=jmaki@openpizza.org 
  #           user[password]=password
  # returns:  { device_pool_driver_id : 1, resource_url : 'https://openpizza.org/ridepilot/v1/device_pool_drivers/1.json' }
  def index
    respond_to do |format|
      format.json do
        render :json => { 
          :device_pool_driver_id => @device_pool_driver.id, 
          :resource_url => v1_device_pool_driver_url(:id => @device_pool_driver.id, :secure => true, :format => "json")
        }, :status => 200
      end
    end
  rescue Exception => e
    render :json => { :error => e.message }, :status => 500
  end
  
private
  
  def authenticate_driver!
    return render_unauthorized if params[:user].blank?      
    
    user = User.find_by_email( params[:user][:email] )
    if user && user.valid_password?(params[:user][:password])
      @current_user = user
    else
      render_unauthorized
    end
  rescue ActiveRecord::RecordNotFound => rnf
    return render :json => { :error => rnf.message }, :status => 404
  rescue Exception => e
    render :json => { :error => e.message }, :status => 500
  end
  
  def authorize_device_pool_driver_for_user!
    @device_pool_driver = params[:id].present? ? DevicePoolDriver.find(params[:id]) : @current_user.device_pool_driver
    render_unauthorized_for_resource if @device_pool_driver.blank? || !authorize!(:update, @device_pool_driver) 
  rescue ActiveRecord::RecordNotFound => rnf
    return render :json => { :error => rnf.message }, :status => 404
  rescue CanCan::AccessDenied => e
    render_unauthorized_for_resource
  rescue Exception => e
    render :json => { :error => e.message }, :status => 500
  end
  
  def render_unauthorized
    render :json => { :error => "No user found for provided user[email] and user[password]."}, :status => 401
  end
  
  def render_unauthorized_for_resource
    render :json => { :error => "User does not have access to this resource."}, :status => 401
  end
  
end
