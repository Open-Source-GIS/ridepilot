class Run < ActiveRecord::Base
  belongs_to :provider
  belongs_to :driver
  belongs_to :vehicle

  has_many :trips, :order=>"pickup_time"

end
