class UnifyDriverNames < ActiveRecord::Migration
  def self.up
    add_column :drivers, :name, :string
    for driver in Driver.find :all
      driver.name = "%s %s" % [driver.first_name, driver.last_name]
      driver.save!
    end
    remove_column :drivers, :first_name
    remove_column :drivers, :last_name

  end

  def self.down
  end
end
