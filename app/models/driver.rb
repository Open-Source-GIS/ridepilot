class Driver < ActiveRecord::Base
  belongs_to :provider
  validates_uniqueness_of :name, :scope => :provider_id


end
