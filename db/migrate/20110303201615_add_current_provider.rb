class AddCurrentProvider < ActiveRecord::Migration
  def self.up
    add_column :users, :current_provider_id, :integer
  end

  def self.down
    remove_column :users, :current_provider_id
  end
end
