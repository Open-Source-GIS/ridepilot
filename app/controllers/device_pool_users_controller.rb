class DevicePoolUsersController < ApplicationController
  load_and_authorize_resource :device_pool
  load_and_authorize_resource :device_pool_user, :through => :device_pool
  
  def create
    @device_pool_user = @device_pool.device_pool_users.build params[:device_pool_user]
    
    if @device_pool_user.save
      render :json => { :row => render_to_string(:partial => "device_pool_user_row.html", :locals => { :device_pool_user => @device_pool_user }) }
    else
      render :json => { :errors => @device_pool_user.errors }
    end
  end
  
  def destroy
    @device_pool_user.destroy
    render :json => {}
  end
end
