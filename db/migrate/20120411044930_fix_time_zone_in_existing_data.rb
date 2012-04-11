class FixTimeZoneInExistingData < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      UPDATE repeating_trips
      SET pickup_time = pickup_time + interval '7 hours',
              appointment_time = appointment_time + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE trips
      SET pickup_time = pickup_time + interval '7 hours',
              appointment_time = appointment_time + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE runs
      SET scheduled_start_time = scheduled_start_time + interval '7 hours',
              scheduled_end_time = scheduled_end_time + interval '7 hours',
              actual_start_time = actual_start_time + interval '7 hours',
              actual_end_time = actual_end_time + interval '7 hours';
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE repeating_trips
      SET pickup_time = pickup_time - interval '7 hours',
              appointment_time = appointment_time - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE trips
      SET pickup_time = pickup_time - interval '7 hours',
              appointment_time = appointment_time - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE runs
      SET scheduled_start_time = scheduled_start_time - interval '7 hours',
              scheduled_end_time = scheduled_end_time - interval '7 hours',
              actual_start_time = actual_start_time - interval '7 hours',
              actual_end_time = actual_end_time - interval '7 hours';
    SQL
  end
end
