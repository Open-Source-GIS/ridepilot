class Vehicle < ActiveRecord::Base
  belongs_to :provider

  validates_length_of :vin, :is=>17
  validates_format_of :vin, :with => /^[^ioq]*$/i
end
