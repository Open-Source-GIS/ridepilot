class AddDriverIdAndVehicleIdToRepeatingTrips < ActiveRecord::Migration
  def self.up
    change_table :repeating_trips do |t|
      t.references :driver
      t.references :vehicle
    end
  end

  def self.down
    change_table :repeating_trips do |t|
      t.remove :driver_id
      t.remove :vehicle_id
    end
  end
end
