class DispatchController < ApplicationController
  
  def index
    authorize! :read, DevicePool
    @device_pools = DevicePool.accessible_by(current_ability)    
  end

end
