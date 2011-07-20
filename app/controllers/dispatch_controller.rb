class DispatchController < ApplicationController
  
  def index
    authorize! :read, DevicePool
    
    @device_tree = DevicePool::Tree.new( DevicePool.accessible_by(current_ability) ).as_json
  end

end
