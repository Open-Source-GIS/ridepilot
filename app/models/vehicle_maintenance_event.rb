class VehicleMaintenanceEvent < ActiveRecord::Base
  belongs_to :provider
  belongs_to :vehicle


end
