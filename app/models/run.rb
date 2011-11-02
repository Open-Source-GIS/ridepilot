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
  
  default_scope order(:date)
  scope :incomplete_on, lambda{ |date| where("complete is not true").where(:date => date) }

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
