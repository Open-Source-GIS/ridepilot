class AddTrimetRegion < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name
    end

    add_column :regions, :the_geom, :polygon, :srid => 4326
    
    add_index :regions, :the_geom, :spatial => true
  end

  def self.down
    drop_table :regions
  end
end
