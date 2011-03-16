class CreateVehicleMaintenance < ActiveRecord::Migration
  def self.up
    create_table :vehicle_maintenance_events do |t|
      t.integer :vehicle_id, :null => false
      t.integer :provider_id, :null => false
      t.boolean :reimbursable
      t.date    :service_date
      t.date    :invoice_date
      t.text    :services_performed
      t.decimal :odometer, :precision=>10, :scale=>1
      t.string  :vendor_name
      t.string  :invoice_number
      t.decimal :invoice_amount, :precision=>10, :scale=>2
    end
  end

  def self.down
    drop_table :vehicle_maintenance
  end
end
