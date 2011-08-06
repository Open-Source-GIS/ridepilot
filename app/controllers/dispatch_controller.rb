class DispatchController < ApplicationController

  def index
    authorize! :read, DevicePool
    
    respond_to do |format|
      format.html
      format.js { 
        render :json => DevicePool::Tree.new( DevicePool.accessible_by(current_ability) ).as_json
      }
    end
  end
  
end
