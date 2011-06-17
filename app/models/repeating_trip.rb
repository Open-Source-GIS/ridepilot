class RepeatingTrip < ActiveRecord::Base
  include ScheduleAttributes

  belongs_to :provider
  belongs_to :customer
  belongs_to :pickup_address, :class_name=>"Address"
  belongs_to :dropoff_address, :class_name=>"Address"
  belongs_to :repeating_trip
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'

  validates_date :pickup_time
  validates_date :appointment_time

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id

  #Create concrete trips from all repeating trips.  This method
  #is idempotent.
  def self.create_trips
    for repeating_trip in RepeatingTrip.all
      repeating_trip.instantiate
    end
  end

  def instantiate
    now = Time.now
    later = now.advance(:days=>21)
    for date in schedule.occurrences_between(now, later)
      this_trip_pickup_time = Time.gm(date.year, date.month, date.day, pickup_time.hour, pickup_time.min, pickup_time.sec)

      if Trip.where("pickup_time = ? and repeating_trip_id=?", this_trip_pickup_time, id).count == 0
        attributes = self.attributes
        attributes["repeating_trip_id"] = id
        attributes.delete "recurrence"
        attributes.delete "schedule_yaml"
        attributes["pickup_time"] = this_trip_pickup_time
        attributes["appointment_time"] = this_trip_pickup_time + (appointment_time - pickup_time)
        Trip.new(attributes).save!
      end
    end
  end

end
