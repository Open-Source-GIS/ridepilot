class Run < ActiveRecord::Base
  belongs_to :provider
  belongs_to :driver
  belongs_to :vehicle

  has_many :trips, :order=>"pickup_time"

  before_validation :set_complete

  def set_complete
    if scheduled_end_time
      date = scheduled_end_time.to_date
    end
    complete = (!actual_start_time.nil?) and (!actual_end_time.nil?) and actual_end_time < DateTime.now and vehicle_id and driver_id

  end

end
