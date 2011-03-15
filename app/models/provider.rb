class Provider < ActiveRecord::Base
  has_many :roles
  has_many :users, :through=>:roles
  has_many :drivers
  has_many :vehicles
  has_many :monthlies
end
