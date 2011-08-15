class ChangeVehiclesAddDefaultDriverId < ActiveRecord::Migration
  def self.up
    add_column :vehicles, :default_driver_id, :integer
  end

  def self.down
    remove_column :vehicles, :default_driver_id
  end
end
