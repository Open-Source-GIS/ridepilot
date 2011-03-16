class Vehicle < ActiveRecord::Base
  belongs_to :provider
  has_many :vehicle_maintenance_events

  default_scope :order => 'active, name'

  validates_length_of :vin, :is=>17
  validates_format_of :vin, :with => /^[^ioq]*$/i
end
