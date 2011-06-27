class ChangeAddressesAddInactiveFlag < ActiveRecord::Migration
  def self.up
    add_column :addresses, :inactive, :boolean, :default => false
    
    Address.all.each {|a| a.update_attribute :inactive, false }
  end

  def self.down
    remove_column :addresses, :inactive
  end
end
