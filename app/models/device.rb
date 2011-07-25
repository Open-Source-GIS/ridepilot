class Device < ActiveRecord::Base
  belongs_to :device_pool
  
  validates :android_id, :presence => true, :uniqueness => true
      
  def as_tree_json
    {
      :data     => active? ? name : "<span class='inactive'>#{name}</span>",
      :attr     => { :rel => "device" },
      :metadata => as_json
    }
  end
  
  def as_json
    { 
      :id         => id, 
      :android_id => android_id,
      :lat        => lat, 
      :lng        => lng, 
      :status     => status 
    }
  end
  
  def active?
    status == "active"
  end
  
  def to_param
    android_id
  end
end
