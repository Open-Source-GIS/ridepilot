class Trip < ActiveRecord::Base
  belongs_to :provider
  belongs_to :run
  belongs_to :client
  default_scope :order => 'pickup_time'

end
