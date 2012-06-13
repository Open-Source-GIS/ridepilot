class AddCustomerInformedToRepeatingTrips < ActiveRecord::Migration
  def self.up
    add_column :repeating_trips, :customer_informed, :boolean
  end

  def self.down
    remove_column :repeating_trips, :customer_informed
  end
end
