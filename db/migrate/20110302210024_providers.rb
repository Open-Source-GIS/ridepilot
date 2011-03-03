class Providers < ActiveRecord::Migration
  def self.up
    create_table :providers do |t|
      t.string :name
    end
    create_table :roles do |t|
      t.references :user
      t.references :provider
      t.boolean :admin
    end
  end

  def self.down
    drop_table :providers
    drop_table :roles
  end
end
