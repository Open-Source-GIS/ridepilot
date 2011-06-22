class ChangeAddressAddPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :addresses, :phone_number, :string
  end

  def self.down
    remove_column :addresses, :phone_number
  end
end
