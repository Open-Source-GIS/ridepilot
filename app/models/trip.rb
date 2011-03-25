class Trip < ActiveRecord::Base
  belongs_to :provider
  belongs_to :run
  belongs_to :customer
  belongs_to :pickup_address, :class_name=>"Address"
  belongs_to :dropoff_address, :class_name=>"Address"
  belongs_to :repeating_trip
  default_scope :order => 'pickup_time'

  serialize :guests
end
