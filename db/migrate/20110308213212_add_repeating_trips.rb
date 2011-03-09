class AddRepeatingTrips < ActiveRecord::Migration
  def self.up
    change_table :trips do |t|
      t.integer :repeating_trip_id
    end

    create_table :repeating_trips do |t|
      t.string   "schedule_yaml"

      t.integer  "provider_id"
      t.integer  "customer_id"
      t.datetime "pickup_time"
      t.datetime "appointment_time"
      t.integer  "guest_count", :default => 0
      t.integer  "attendant_count", :default => 0
      t.integer  "group_size", :default => 0
      t.integer  "pickup_address_id"
      t.integer  "dropoff_address_id"
      t.integer  "mobility_id"
      t.integer  "funding_source_id"
      t.string   "trip_purpose"
      t.string   "notes"
    end
  end

  def self.down
    change_table :trips do |t|
      t.remove :repeating_trip_id
    end
    remove_table :repeating_trips
  end
end
