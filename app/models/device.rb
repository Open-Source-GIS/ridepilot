class Device < ActiveRecord::Base
  belongs_to :device_pool
  
  validates :android_id, :presence => true
    
  def as_json
    {
      :data     => active? ? name : "<span class='inactive'>#{name}</span>",
      :attr     => { :rel => "device" },
      :metadata => { 
        :id     => id, 
        :lat    => lat, 
        :lng    => lng, 
        :status => status 
      }
    }
  end
  
  def active?
    status == "active"
  end
end
