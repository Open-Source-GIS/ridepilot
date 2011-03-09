class RepeatingTrip < ActiveRecord::Base
  include ScheduleAttributes

  belongs_to :provider
  belongs_to :customer
  belongs_to :pickup_address, :class_name=>"Address"
  belongs_to :dropoff_address, :class_name=>"Address"
  belongs_to :repeating_trip


  #Create concrete trips from all repeating trips.  This method
  #is idempotent.
  def self.create_trips
    for repeating_trip in RepeatingTrip.all

      pickup_time = repeating_trip.recurrence.next_occurence

      if Trip.where("pickup_time = ? and repeating_trip_id=?", pickup_time, id).count == 0

        attributes = repeating_trip.attributes
        attributes["repeating_trip_id"] = id
        attributes.delete "recurrence"
        attributes["pickup_time"] = pickup_time
        
        Trip.new(attributes).save!
      end
    end
  end  

end
