class ChangeDevicesAddAndroidId < ActiveRecord::Migration
  def self.up
    add_column :devices, :android_id, :string
  end

  def self.down
    remove_column :devices, :android_id
  end
end
