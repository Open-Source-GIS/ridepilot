class Run < ActiveRecord::Base
  belongs_to :provider
  belongs_to :driver
  belongs_to :vehicle
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'

  has_many :trips, :order=>"pickup_time"

  before_validation :set_complete

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
  
  accepts_nested_attributes_for :trips
  
  scope :for_provider, lambda{|provider_id| where( :provider_id => provider_id ) }
  scope :for_paid_driver, where(:paid => true)
  scope :for_volunteer_driver, where(:paid => false)
  scope :incomplete_on, lambda{|date| where(:complete => false, :date => date) }
  scope :for_date_range, lambda{|start_date, end_date| where("runs.date >= ? and runs.date < ?", start_date, end_date) }
  scope :with_odometer_readings, where("start_odometer IS NOT NULL and end_odometer IS NOT NULL")

  def cab=(value)
    @cab = value
  end

  def set_complete
    if scheduled_end_time
      date = scheduled_end_time.to_date
    end
    complete = (!actual_start_time.nil?) and (!actual_end_time.nil?) and actual_end_time < DateTime.now and vehicle_id and driver_id and trips.all? &:complete
    true
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

end
