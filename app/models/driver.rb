class Driver < ActiveRecord::Base
  belongs_to :provider
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'
  validates_uniqueness_of :name, :scope => :provider_id
  validates_length_of :name, :minimum=>2

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
end
