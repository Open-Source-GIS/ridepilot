class Trip < ActiveRecord::Base
  attr_accessor :driver_id, :vehicle_id, :via_repeating_trip

  belongs_to :provider
  belongs_to :run
  belongs_to :customer
  belongs_to :funding_source
  belongs_to :mobility
  belongs_to :pickup_address, :class_name=>"Address"
  belongs_to :dropoff_address, :class_name=>"Address"
  belongs_to :called_back_by, :class_name=>"User"
  belongs_to :repeating_trip
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'

  serialize :guests

  before_validation :compute_in_district
  before_validation :compute_run
  
  validates_presence_of :pickup_address
  validates_presence_of :dropoff_address
  validates_presence_of :pickup_time
  validates_presence_of :appointment_time
  validates_presence_of :trip_purpose

  validate :driver_is_valid_for_vehicle

  validates_associated :pickup_address
  validates_associated :dropoff_address

  accepts_nested_attributes_for :customer

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
  
  scope :for_cab, where(:cab => true)
  scope :not_for_cab, where(:cab => false)
  scope :for_provider, lambda { |provider_id| where( :provider_id => provider_id ) }
  scope :for_date, lambda{|date| where('CAST(trips.pickup_time AS date) = CAST(? AS date)', date) }
  scope :for_date_range, lambda{|start_date, end_date| where('trips.pickup_time >= ? AND trips.pickup_time < ?', start_date, end_date) }
  scope :for_driver, lambda{|driver_id| not_for_cab.where(:runs => {:driver_id => driver_id}).joins(:run) }
  scope :scheduled, where("trips.trip_result = '' OR trips.trip_result = 'COMP'")
  scope :completed, where(:trip_result => 'COMP')
  scope :today_and_prior, where('CAST(trips.pickup_time AS date) <= ?', Date.today)
  scope :after_today, where('CAST(trips.pickup_time AS date) > ?', Date.today)
  scope :prior_to, lambda{|pickup_time| where('trips.pickup_time < ?', pickup_time)}
  scope :after, lambda{|pickup_time| where('trips.pickup_time > ?', pickup_time)}
  scope :repeating_based_on, lambda{|repeating_trip| where(:repeating_trip_id => repeating_trip.id)}

  def date
    pickup_time.to_date
  end

  def complete
    trip_result == 'COMP'
  end

  def vehicle_id
    run ? run.vehicle_id : @vehicle_id
  end

  def driver_id
    @driver_id || run.try(:driver_id)
  end
  
  def pickup_time=(datetime)
    write_attribute :pickup_time, format_datetime( datetime )
  end
  
  def appointment_time=(datetime)
    write_attribute :appointment_time, format_datetime( datetime )
  end

  def run_text
    if cab
      "Cab"
    elsif run
      run.label
    else
      "(No run specified)"
    end
  end

  private
  
  def format_datetime(datetime)
    datetime.is_a?( String ) && %w{a p}.include?( datetime.last.downcase ) ? "#{datetime}m" : datetime
  end

  def driver_is_valid_for_vehicle
    # This will error if a run was found or extended for this vehicle and time, but the driver for the run is not the driver selected for the trip
    if self.run.try(:driver_id).present? && self.driver_id.present? && self.run.driver_id.to_i != self.driver_id.to_i
      errors[:driver_id] << "is not the driver for the selected vehicle during this vehicle's run."
    end
  end

  def compute_in_district
    return if !pickup_address or !dropoff_address

    self.in_district = pickup_address.in_district && dropoff_address.in_district
  end

  def compute_run    
    return if run_id || cab || vehicle_id.blank? || provider_id.blank?

    if !pickup_time or !appointment_time 
      return #we'll error out in validation
    end

    #when the trip is saved, we need to find or create a run for it.
    #this will depend on the driver and vehicle.  
    self.run = Run.find(:first, :conditions=>["scheduled_start_time <= ? and scheduled_end_time >= ? and vehicle_id=? and provider_id=?", pickup_time, appointment_time, vehicle_id, provider_id])

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
            self.run = make_run
          else
            self.run = previous_run
            previous_run.update_attributes! :scheduled_end_time => run.appointment_time
          end
        end
      else
        if next_run and next_run.scheduled_start_time < appointment_time
          #just the next run
          if next_run.scheduled_start_time.to_date != pickup_time.to_date
            self.run = make_run
          else
            self.run = next_run
            next_run.update_attributes! :scheduled_start_time => run.pickup_time
          end
        else
          #no overlap, create a new run
          self.run = make_run
        end
      end
    end

  end

  def handle_overlapping_runs(previous_run, next_run)
    #can we unify the runs?
    if next_run.driver_id == previous_run.driver_id
      self.run = unify_runs(previous_run, next_run)
      return
    end

    #now, can we push the start of the second run later?
    first_trip = next_run.trips.find(:first)
    if first_trip.scheduled_start_time > appointment_time
      #yes, we can
      next_run.update_attributes! :scheduled_start_time => appointment_time
      previous_run.update_attributes! :scheduled_end_time => appointment_time
      self.run = previous_run
    else
      #no, the second run is fixed.  Can we push the end of the
      #first run earlier?
      last_trip = previous_run.trips.find(:last)
      if last_trip.scheduled_end_time <= pickup_time
        #yes, we can
        previous_run.update_attributes! :scheduled_end_time => pickup_time
        next_run.update_attributes! :scheduled_start_time => appointment_time
        self.run = next_run
      else
        return false
      end
    end
  end

  def unify_runs(before, after)
    before.update_attributes! :scheduled_end_time => after.scheduled_end_time, :end_odometer => after.end_odometer
    for trip in after.trips
      trip.run = before
    end
    after.destroy
    return before
  end

  def make_run
    Run.create({
      :provider_id          => provider_id,
      :date                 => pickup_time.to_date,
      :scheduled_start_time => DateTime.new( pickup_time.year, pickup_time.month, pickup_time.day, DEFAULT_RUN_START_HOUR, 0, 0),
      :scheduled_end_time   => DateTime.new( pickup_time.year, pickup_time.month, pickup_time.day, DEFAULT_RUN_END_HOUR, 0, 0),
      :vehicle_id           => vehicle_id,
      :driver_id            => driver_id,
      :complete             => false,
      :paid                 => true
    })
  end

end
