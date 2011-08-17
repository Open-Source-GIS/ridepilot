class Vehicle < ActiveRecord::Base
  belongs_to :provider
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'
  belongs_to :default_driver, :class_name => "Driver"
  
  has_many :vehicle_maintenance_events

  default_scope :order => 'active, name'
  scope :active, :conditions => { :active => true }
  scope :for_provider, lambda { |provider_id| where(:provider_id => provider_id) }

  validates_length_of :vin, :is=>17, :allow_nil => true
  validates_format_of :vin, :with => /^[^ioq]*$/i, :allow_nil => true

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
end
