class Trip < ActiveRecord::Base
  belongs_to :provider
  belongs_to :run
  belongs_to :customer
  belongs_to :pickup_address, :class_name=>"Address"
  belongs_to :dropoff_address, :class_name=>"Address"
  belongs_to :repeating_trip
  default_scope :order => 'pickup_time'

  serialize :guests

  before_save :compute_in_district
  validates_presence_of :pickup_address
  validates_presence_of :dropoff_address


  def compute_in_district
    in_district = pickup_address.in_district && dropoff_address.in_district
  end

end
