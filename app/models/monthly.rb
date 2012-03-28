class Monthly < ActiveRecord::Base
  belongs_to :provider

  validates_uniqueness_of :start_date

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
end
