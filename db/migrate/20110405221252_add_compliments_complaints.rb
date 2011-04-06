class AddComplimentsComplaints < ActiveRecord::Migration
  def self.up
    change_table :monthlies do |t|
      t.integer :complaints
      t.integer :compliments
    end
  end

  def self.down
    change_table :monthlies do |t|
      t.remove :complaints
      t.remove :compliments
    end
  end
end
