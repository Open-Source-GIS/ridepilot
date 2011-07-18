class Device < ActiveRecord::Base
  belongs_to :device_pool
  
  validates :name, :presence => true
end
