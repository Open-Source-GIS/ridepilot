class AddHouseKeeping < ActiveRecord::Migration
  def self.up
    for table in [:addresses, :customers, :drivers, :monthlies, :repeating_trips, :runs, :trips, :vehicle_maintenance_events, :vehicles]

      change_table table do |t|
        t.datetime :created_at
        t.datetime :updated_at
        t.integer :created_by_id
        t.integer :updated_by_id
        t.integer :lock_version, :default=>0
      end
    end
  end

  def self.down
    for table in [:addresses, :customers, :drivers, :monthlies, :repeating_trips, :runs, :trips, :vehicle_maintennance_events, :vehicles]

      change_table table do |t|
        t.remove :created_at
        t.remove :updated_at
        t.remove :created_by_id
        t.remove :updated_by_id
        t.remove :lock_version
      end
    end
  end
end
