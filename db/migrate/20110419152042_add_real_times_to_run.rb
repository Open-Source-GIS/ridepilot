class AddRealTimesToRun < ActiveRecord::Migration
  def self.up
    rename_column :runs, :start_time, :scheduled_start_time
    rename_column :runs, :end_time, :scheduled_end_time
    add_column :runs, :actual_start_time, :timestamp
    add_column :runs, :actual_end_time, :timestamp
  end

  def self.down
  end
end
