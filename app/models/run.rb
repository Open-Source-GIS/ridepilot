class Run < ActiveRecord::Base
  belongs_to :provider
  belongs_to :driver

end
