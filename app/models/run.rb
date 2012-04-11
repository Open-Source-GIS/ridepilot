class Run < ActiveRecord::Base
  belongs_to :provider
  belongs_to :driver
  belongs_to :vehicle
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'

  has_many :trips, :order=>"pickup_time"

  before_validation :set_complete, :fix_dates

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
  
  accepts_nested_attributes_for :trips
  
  validates_datetime :scheduled_end_time, :after => :scheduled_start_time, :allow_nil => true
  validates_datetime :actual_end_time, :after => :actual_start_time, :allow_nil => true
  validates_date :date
  validates_numericality_of :start_odometer, :allow_nil => true
  validates_numericality_of :end_odometer, :allow_nil => true
  validates_numericality_of :end_odometer, :allow_nil => true, 
    :greater_than => Proc.new {|run| run.start_odometer }, 
    :if => Proc.new {|run| run.start_odometer.present? }  
  validates_numericality_of :end_odometer, :allow_nil => true, 
    :less_than => Proc.new {|run| run.start_odometer + 500 }, 
    :if => Proc.new {|run| run.start_odometer.present? }  
  validates_numericality_of :unpaid_driver_break_time, :allow_nil => true
  
  scope :for_provider, lambda {|provider_id| where( :provider_id => provider_id ) }
  scope :for_vehicle, lambda {|vehicle_id| where(:vehicle_id => vehicle_id )}
  scope :for_paid_driver, where(:paid => true)
  scope :for_volunteer_driver, where(:paid => false)
  scope :incomplete_on, lambda {|date| where(:complete => false, :date => date) }
  scope :for_date_range, lambda {|start_date, end_date| where("runs.date >= ? and runs.date < ?", start_date, end_date) }
  scope :with_odometer_readings, where("start_odometer IS NOT NULL and end_odometer IS NOT NULL")

  def cab=(value)
    @cab = value
  end

  def vehicle_name
    vehicle.name if vehicle.present?
  end
  
  def label
    if @cab
      "Cab"
    else
      "#{vehicle_name}: #{driver.try :name} #{scheduled_start_time.try :strftime, "%I:%M%P"}".gsub( /m$/, "" )
    end
  end
  
  def as_json(options)
    { :id => id, :label => label }
  end

  private

  def set_complete
    self.complete = ((!actual_start_time.nil?) && (!actual_end_time.nil?) && actual_end_time < DateTime.now && vehicle_id && driver_id && (trips.none? &:pending))
    true
  end

  def fix_dates 
    d = self.date
    unless d.nil?
      unless scheduled_start_time.nil?
        s = scheduled_start_time 
        self.scheduled_start_time = Time.zone.local(d.year, d.month, d.day, s.hour, s.min, 0) 
      end
      unless scheduled_end_time.nil?
        s = scheduled_end_time
        self.scheduled_end_time = Time.zone.local(d.year, d.month, d.day, s.hour, s.min, 0) 
      end
      unless actual_start_time.nil?
        a = actual_start_time
        self.actual_start_time = Time.zone.local(d.year, d.month, d.day, a.hour, a.min, 0) 
      end
      unless actual_end_time.nil?
        a = actual_end_time
        self.actual_end_time = Time.zone.local(d.year, d.month, d.day, a.hour, a.min, 0)
      end
    end
    true
  end
end
