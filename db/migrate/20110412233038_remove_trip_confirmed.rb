class RemoveTripConfirmed < ActiveRecord::Migration
  def self.up
    change_table :trips do |t|
      t.remove :trip_confirmed
    end
  end

  def self.down
  end
end
