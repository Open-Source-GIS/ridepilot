class AddCabStatusToTrip < ActiveRecord::Migration
  def self.up
    change_table :trips do |t|
      t.boolean :cab, :default=>false
      t.boolean :cab_notified, :default=>false
    end
  end

  def self.down
    change_table :trips do |t|
      t.remove :cab
      t.remove :cab_notified
    end
  end
end
