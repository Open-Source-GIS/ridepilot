class AddActiveToVehicles < ActiveRecord::Migration
  def self.up
    change_table :vehicles do |t|
      t.boolean :active, :default=>true
    end
  end

  def self.down
    change_table :vehicles do |t|
      t.remove :active
    end
  end
end
