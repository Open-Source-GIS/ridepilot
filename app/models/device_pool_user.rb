class DevicePoolUser < ActiveRecord::Base
  belongs_to :device_pool
  belongs_to :user
  has_one    :driver, :through => :user
  
  validates :user, :presence => true, :uniqueness => true
  validates :device_pool, :presence => true
  
  # validate that user is a driver ?
  # validate that the device_pool's provider is the same as the driver's provider ? can this be enforced with authorization ?
      
  def as_tree_json
    {
      :data     => active? ? name : "<span class='inactive'>#{name}</span>",
      :attr     => { :rel => "device" },
      :metadata => as_json
    }
  end
  
  def as_json
    { 
      :id             => id, 
      :name           => name,
      :device_pool_id => device_pool_id,
      :user_id        => user_id,
      :lat            => lat, 
      :lng            => lng, 
      :status         => status 
    }
  end
  
  def active?
    status == "active"
  end
  
  def name
    driver.name
  end
end
