class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :name, :status
      t.float :lat, :lng
      t.integer :driver_id, :device_pool_id
      t.timestamps
    end
    
    add_index :devices, :device_pool_id
  end

  def self.down
    drop_table :devices
  end
end
