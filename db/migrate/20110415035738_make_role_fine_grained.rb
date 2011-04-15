class MakeRoleFineGrained < ActiveRecord::Migration
  def self.up
    change_table :roles do |t|
      t.integer :level
    end
    for role in Role.all
      role.level = role.admin ? 0 : 100
    end
    change_table :roles do |t|
      t.remove :admin
    end
  end

  def self.down
  end
end
