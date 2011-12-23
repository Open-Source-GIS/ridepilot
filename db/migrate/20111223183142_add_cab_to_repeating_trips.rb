class AddCabToRepeatingTrips < ActiveRecord::Migration
  def self.up
    change_table :repeating_trips do |t|
      t.boolean :cab, :default => false
    end
  end

  def self.down
    change_table :repeating_trips do |t|
      t.remove :cab
    end
  end
end
