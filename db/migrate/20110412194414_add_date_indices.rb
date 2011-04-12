class AddDateIndices < ActiveRecord::Migration
  def self.up
    add_index :trips, [:provider_id, :pickup_time]
    add_index :trips, [:provider_id, :appointment_time]
    add_index :runs, [:provider_id, :date]
    add_index :runs, [:provider_id, :start_time]

  end

  def self.down
  end
end
