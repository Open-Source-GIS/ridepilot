class AddVehicleIdToDevicePoolDrivers < ActiveRecord::Migration
  def self.up
    change_table :device_pool_drivers do |t|
      t.integer :vehicle_id
    end
  end

  def self.down
    change_table :device_pool_drivers do |t|
      t.remove :vehicle_id
    end
  end
end
