class CreateTravelTime < ActiveRecord::Migration
  def self.up
    create_table "travel_time_estimates", :id=>false do |t|
      t.integer :from_address_id, :references=>:addresses
      t.integer :to_address_id, :references=>:addresses
      t.integer :seconds
    end
  end

  def self.down
    drop_table "travel_time_estimates"
  end
end
