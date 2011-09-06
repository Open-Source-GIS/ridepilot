class ChangeDevicesToDevicePoolUsers < ActiveRecord::Migration
  def self.up
    rename_table :devices, :device_pool_users
    
    remove_column :device_pool_users, :android_id
    remove_column :device_pool_users, :driver_id
    remove_column :device_pool_users, :name
    
    add_column :device_pool_users, :user_id, :integer
    add_index :device_pool_users, :user_id
  end

  def self.down
    remove_column :device_pool_users, :user_id
    
    add_column :device_pool_users, :android_id, :string
    add_column :device_pool_users, :name, :string
    add_column :device_pool_users, :driver_id, :integer
    
    rename_table :device_pool_users, :devices
  end
end
