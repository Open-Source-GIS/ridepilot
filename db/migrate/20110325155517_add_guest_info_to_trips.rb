class AddGuestInfoToTrips < ActiveRecord::Migration
  def self.up
    change_table :trips do |t|
      t.text :guests
    end
  end

  def self.down
    change_table :trips do |t|
      t.remove :guests
    end
  end
end
