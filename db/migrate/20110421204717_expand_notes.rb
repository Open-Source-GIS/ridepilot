class ExpandNotes < ActiveRecord::Migration
  def self.up
    change_column :customers, :mobility_notes, :text
    change_column :customers, :private_notes, :text
    change_column :customers, :public_notes, :text
    change_column :customers, :emergency_contact_notes, :text
    change_column :repeating_trips, :notes, :text
    change_column :trips, :notes, :text
  end

  def self.down
    change_column :customers, :mobility_notes, :string
    change_column :customers, :private_notes, :string
    change_column :customers, :public_notes, :string
    change_column :customers, :emergency_contact_notes, :string
    change_column :repeating_trips, :notes, :string
    change_column :trips, :notes, :string
  end
end
