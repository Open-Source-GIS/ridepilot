class ChangeUsersDriversAndDevicePoolUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :driver_id
    add_column    :drivers, :user_id, :integer
    
    rename_table  :device_pool_users, :device_pool_drivers
    rename_column :device_pool_drivers, :user_id, :driver_id
  end

  def self.down
    rename_column :device_pool_drivers, :driver_id, :user_id
    rename_table  :device_pool_drivers, :device_pool_users
    
    remove_column :drivers, :user_id
    add_column    :users, :driver_id, :integer
  end
end
