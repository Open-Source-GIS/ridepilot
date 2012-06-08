class DevicePoolDriver < ActiveRecord::Base
  attr_accessible :lat, :lng, :status, :posted_at
  
  belongs_to :device_pool
  belongs_to :driver
  belongs_to :vehicle
  has_one    :user, :through => :driver
  
  Statuses = %w{inactive active break}
  
  validates :driver_id, :uniqueness => true, :allow_nil => true
  validates :vehicle_id, :uniqueness => true, :allow_nil => true
  validates :device_pool, :presence => true
  validates :status, :inclusion => { :in => Statuses, :message => "must be in #{Statuses.inspect}", :allow_nil => true }
  validate  :require_driver_or_vehicle
  
  def lat=(coord)
    write_attribute(:lat, coord) if coord.present?
  end
  
  def lng=(coord)
    write_attribute(:lng, coord) if coord.present?
  end
  
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
      :driver_id      => driver_id,
      :vehicle_id     => vehicle_id,
      :lat            => lat, 
      :lng            => lng, 
      :status         => status,
      :active         => active?,
      :posted_at      => posted_at.try(:strftime, "%m/%d/%Y %I:%M %p")
    }
  end
  
  def as_mobile_json
    {
      :lat        => lat, 
      :lng        => lng, 
      :status     => status,
      :posted_at  => posted_at
    }
  end
  
  def active?
    status == "active"
  end
  
  def name
    if driver.present?
      "Driver: #{driver.name}" 
    elsif vehicle.present?
      "Vehicle: #{vehicle.name}"
    end
  end
  
  def provider_id
    device_pool.provider_id
  end

private
  
  def require_driver_or_vehicle
    unless (vehicle_id.present? || driver_id.present?) && !(vehicle_id.present? && driver_id.present?)
      errors.add(:base, "Record must have either an associated driver or an associated vehicle") 
    end
  end

end
