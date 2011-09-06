class ChangeUsersAddDriverId < ActiveRecord::Migration
  def self.up
    add_column :users, :driver_id, :integer
    add_index :users, :driver_id
  end

  def self.down
    remove_column :users, :driver_id
  end
end
