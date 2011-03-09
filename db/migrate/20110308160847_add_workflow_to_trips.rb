class AddWorkflowToTrips < ActiveRecord::Migration
  def self.up
    change_table :trips do |t|
      t.date :called_back_at
      t.boolean :customer_informed
    end
  end

  def self.down
    change_table :trips do |t|
      t.remove :called_back_at
      t.remove :customer_informed
    end
  end
end
