class AddMonthly < ActiveRecord::Migration
  def self.up
    create_table :monthlies do |t|
      t.date :start_date
      t.date :end_date
      t.integer :volunteer_escort_hours
      t.integer :volunteer_admin_hours
    end
  end

  def self.down
    drop_table :monthlies
  end
end
