class DevicePool < ActiveRecord::Base
  belongs_to  :provider
  has_many    :devices
  
  validates :name, :presence => true
  validates :color, :presence => true
  
  validates :color, :length => { :is => 6, :if => lambda { self.color.present? } }
  
end
