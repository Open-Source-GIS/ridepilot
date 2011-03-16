class AddProviderIdToMonthlies < ActiveRecord::Migration
  def self.up
    change_table :monthlies do |t|
      t.integer  "provider_id"
    end
  end

  def self.down
    change_table :monthlies do |t|
      t.remove  "provider_id"
    end
  end
end
