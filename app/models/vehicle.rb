class Vehicle < ActiveRecord::Base
  belongs_to :provider
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'
  has_many :vehicle_maintenance_events

  default_scope :order => 'active, name'
  named_scope :active, :conditions => { :active => true }

  validates_length_of :vin, :is=>17
  validates_format_of :vin, :with => /^[^ioq]*$/i

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
end
