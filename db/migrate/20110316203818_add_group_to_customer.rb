class AddGroupToCustomer < ActiveRecord::Migration
  def self.up
    change_table :customers do |t|
      t.boolean :group, :default=>false
    end
  end

  def self.down
    change_table :customers do |t|
      t.remove :group
    end
  end
end
