class DispatchController < ApplicationController
  include HTTParty
  base_uri "https://#{APP_CONFIG[:host]}"
  
  def index
    authorize! :read, DevicePool
    
    @device_tree = DevicePool::Tree.new( DevicePool.accessible_by(current_ability) ).as_json
  end
  
  def test_api
    req     =  self.class.post( "/v1/device_pool_drivers/#{params[:device_pool_driver][:id]}.json", { :query => params } )
    render :json => req.to_json
  end

end
