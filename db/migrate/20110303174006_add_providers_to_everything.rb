class AddProvidersToEverything < ActiveRecord::Migration
  def self.up
    rename_table :driver, :drivers
    rename_table :client, :clients

    add_column :addresses, :provider_id, :integer
    add_column :clients, :provider_id, :integer
    add_column :drivers, :provider_id, :integer
    add_column :runs, :provider_id, :integer
    add_column :trips, :provider_id, :integer
    add_column :vehicles, :provider_id, :integer

  end

  def self.down
    remove_column :addresses, :provider_id
    remove_column :clients, :provider_id
    remove_column :drivers, :provider_id
    remove_column :runs, :provider_id
    remove_column :trips, :provider_id
    remove_column :vehicles, :provider_id

    rename_table :drivers, :driver
    rename_table :clients, :client

  end
end
