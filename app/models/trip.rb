class Trip < ActiveRecord::Base
  belongs_to :provider
  belongs_to :run
  belongs_to :customer
  default_scope :order => 'pickup_time'

end
