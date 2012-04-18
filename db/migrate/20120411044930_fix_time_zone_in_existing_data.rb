class FixTimeZoneInExistingData < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      UPDATE addresses
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE customers
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE device_pool_drivers 
      SET posted_at = posted_at + interval '7 hours',
              created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE device_pools
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE drivers
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE monthlies
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE providers
      SET logo_updated_at = logo_updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE repeating_trips
      SET pickup_time = pickup_time + interval '7 hours',
              appointment_time = appointment_time + interval '7 hours',
              created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE runs
      SET scheduled_start_time = scheduled_start_time + interval '7 hours',
              scheduled_end_time = scheduled_end_time + interval '7 hours',
              actual_start_time = actual_start_time + interval '7 hours',
              actual_end_time = actual_end_time + interval '7 hours',
              created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE trips
      SET pickup_time = pickup_time + interval '7 hours',
              appointment_time = appointment_time + interval '7 hours',
              called_back_at = called_back_at + interval '7 hours',
              created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE users
      SET remember_created_at = remember_created_at + interval '7 hours',
              current_sign_in_at = current_sign_in_at + interval '7 hours',
              last_sign_in_at = last_sign_in_at + interval '7 hours',
              created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE vehicle_maintenance_events
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE vehicles
      SET created_at = created_at + interval '7 hours',
              updated_at = updated_at + interval '7 hours';
    SQL
  end

  def self.down
    execute <<-SQL
      UPDATE addresses
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE customers
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE device_pool_drivers
      SET posted_at = posted_at - interval '7 hours',
              created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE device_pools
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE drivers
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE monthlies
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE providers
      SET logo_updated_at = logo_updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE repeating_trips
      SET pickup_time = pickup_time - interval '7 hours',
              appointment_time = appointment_time - interval '7 hours',
              created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE runs
      SET scheduled_start_time = scheduled_start_time - interval '7 hours',
              scheduled_end_time = scheduled_end_time - interval '7 hours',
              actual_start_time = actual_start_time - interval '7 hours',
              actual_end_time = actual_end_time - interval '7 hours',
              created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE trips
      SET pickup_time = pickup_time - interval '7 hours',
              appointment_time = appointment_time - interval '7 hours',
              called_back_at = called_back_at - interval '7 hours',
              created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE users
      SET remember_created_at = remember_created_at - interval '7 hours',
              current_sign_in_at = current_sign_in_at - interval '7 hours',
              last_sign_in_at = last_sign_in_at - interval '7 hours',
              created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE vehicle_maintenance_events
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL

    execute <<-SQL
      UPDATE vehicles
      SET created_at = created_at - interval '7 hours',
              updated_at = updated_at - interval '7 hours';
    SQL
  end
end
