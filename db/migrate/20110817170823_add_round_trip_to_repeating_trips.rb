class AddRoundTripToRepeatingTrips < ActiveRecord::Migration
  def self.up
    add_column :repeating_trips, :round_trip, :boolean
  end

  def self.down
    remove_column :repeating_trips, :round_trip, :boolean
  end
end
