class Trip < ActiveRecord::Base
  belongs_to :provider
  belongs_to :run
  belongs_to :customer
  belongs_to :pickup_address, :class_name=>"Address"
  belongs_to :dropoff_address, :class_name=>"Address"
  belongs_to :repeating_trip
  default_scope :order => 'pickup_time'

  serialize :guests

  before_validation :compute_in_district
  before_validation :compute_run
  validates_presence_of :pickup_address
  validates_presence_of :dropoff_address

  accepts_nested_attributes_for :customer

  def complete
    return trip_result == 'COMP'
  end

  def vehicle_id=(vehicle_id)
      @vehicle_id = vehicle_id
  end

  def vehicle_id
    run ? run.vehicle_id : @vehicle_id
  end

  def compute_in_district
    in_district = pickup_address.in_district && dropoff_address.in_district
  end

  def compute_run
    if run
      return
    end
    #when the trip is saved, we need to find or create a run for it.
    #this will depend on the driver and vehicle.  
    run = Run.find(:first, :conditions=>["scheduled_start_time <= ? and scheduled_end_time >= ? and vehicle_id=? and provider_id=?", pickup_time, appointment_time, vehicle_id, provider_id])
    if run.nil?
      #find the next/previous runs for this vehicle and, if necessary,
      #split or change times on them

      previous_run = Run.find(:last, :conditions=>["scheduled_start_time <= ? and vehicle_id=? and provider_id=? ", appointment_time, vehicle_id, provider_id], :order=>"scheduled_start_time")

      next_run = Run.find(:first, :conditions=>["scheduled_start_time >= ? and vehicle_id=? and provider_id=? ", pickup_time, vehicle_id, provider_id], :order=>"scheduled_start_time")

      #there are four possible cases: either the previous or the next run
      #could overlap the trip, or neither could.

      if previous_run and previous_run.scheduled_end_time > pickup_time
        #previous run overlaps trip
        if next_run and next_run.scheduled_start_time < appointment_time
          #next run overlaps trip too
          return handle_overlapping_runs(previous_run, next_run)
        else
          #just the previous run
          if previous_run.scheduled_start_time.to_date != pickup_time.to_date
            run = make_run()
          else
            run = previous_run
            previous_run.scheduled_end_time = run.appointment_time
          end
        end
      else
        if next_run and next_run.scheduled_start_time < appointment_time
          #just the next run
          if next_run.scheduled_start_time.to_date != pickup_time.to_date
            run = make_run()
          else
            run = next_run
            next_run.scheduled_start_time = run.pickup_time
          end
        else
          #no overlap, create a new run
          run = make_run()
        end
      end
    end

  end

  private
  def handle_overlapping_runs(previous_run, next_run)
    #can we unify the runs?
    if next_run.driver_id == previous_run.driver_id
      run = unify_runs(previous_run, next_run)
      return
    end

    #now, can we push the start of the second run later?
    first_trip = next_run.trips.find(:first)
    if first_trip.scheduled_start_time > appointment_time
      #yes, we can
      next_run.scheduled_start_time = appointment_time
      previous_run.scheduled_end_time = appointment_time
      run = previous_run
    else
      #no, the second run is fixed.  Can we push the end of the
      #first run earlier?
      last_trip = previous_run.trips.find(:last)
      if last_trip.scheduled_end_time <= pickup_time
        #yes, we can
        previous_run.scheduled_end_time = pickup_time
        next_run.scheduled_start_time = appointment_time
        run = next_run
      else
        return false
      end
    end
  end

  def unify_runs(before, after)
    before.scheduled_end_time = after.scheduled_end_time
    before.end_odometer = after.end_odometer

    for trip in after.runs
      trip. run = before
    end
    return before
  end

  def make_run
    return Run.create ({
                      :provider_id=>provider_id,
                      :date => pickup_time.to_date,
                      :scheduled_start_time=>DateTime.new(pickup_time.year,
                                                pickup_time.month,
                                                pickup_time.day,
                                                DEFAULT_RUN_START_HOUR,
                                                0, 0),
                      :scheduled_end_time=>DateTime.new(pickup_time.year,
                                              pickup_time.month,
                                              pickup_time.day,
                                              DEFAULT_RUN_END_HOUR,
                                              0, 0),
                      :vehicle_id=>vehicle_id,
                      :complete=>false,
                      :paid=>true})
  end

end
