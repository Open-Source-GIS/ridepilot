class Driver < ActiveRecord::Base
  belongs_to :provider
  validates_uniqueness_of :name, :scope => :provider_id
  validates_length_of :name, :minimum=>2

end
