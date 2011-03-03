class AddLatLonToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :the_geom, :point, :srid => 4326
    add_index :addresses, :the_geom, :spatial => true
  end

  def self.down
    remove_colum :addressses, :the_geom
  end
end
