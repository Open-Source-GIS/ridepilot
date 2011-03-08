class AddDefaultsForWorkflow < ActiveRecord::Migration
  def self.up
    change_column_default :trips, :customer_informed, :false
    change_column_default :trips, :trip_result, "unscheduled"
  end

  def self.down
    change_column_default :trips, :customer_informed, nil
    change_column_default :trips, :trip_result, nil
  end
end
