class Defaults < ActiveRecord::Migration
  def self.up
    change_column_default(:trips, :guest_count, 0)
    change_column_default(:trips, :attendant_count, 0)
    change_column_default(:trips, :group_size, 0)
    change_column_default(:trips, :donation, 0)
  end

  def self.down
    change_column_default(:trips, :guest_count, nil)
    change_column_default(:trips, :attendant_count, nil)
    change_column_default(:trips, :group_size, nil)
    change_column_default(:trips, :donation, nil)
  end
end
