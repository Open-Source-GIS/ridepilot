class InitDb < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :name
      t.string :building_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.boolean :in_district
    end

    create_table :client do |t|
      t.string :first_name
      t.string :middle_initial
      t.string :last_name
      t.string :phone_number_1
      t.string :phone_number_2
      t.references :address
      t.string :email
      t.date :activated_date
      t.date :inactivated_date
      t.string :inactivated_reason
      t.date :birth_date
      t.references :mobility
      t.string :mobility_notes
      t.string :ethnicity
      t.string :emergency_contact_notes
      t.string :private_notes
      t.string :public_notes
    end

    create_table :driver do |t|
      t.string :first_name
      t.string :last_name
      t.boolean :active
      t.boolean :paid
    end

    create_table :mobilities do |t|
      t.string :name
    end

    create_table :funding_sources do |t|
      t.string :name
    end

    create_table :vehicles do |t|
      t.string :name
      t.integer :year
      t.string :make
      t.string :model
      t.string :license_plate
      t.string :vin
      t.string :garaged_location
    end

    create_table :runs do |t|
      t.string :name
      t.date :date
      t.integer :start_odometer
      t.integer :end_odometer
      t.datetime :start_time
      t.datetime :end_time
      t.integer :unpaid_driver_break_time
      t.references :vehicle
      t.references :driver
      t.boolean :paid
      t.boolean :complete
    end

    create_table :trips do |t|
      t.references :run
      t.references :client
      t.datetime :pickup_time
      t.datetime :appointment_time
      t.integer :guest_count
      t.integer :attendant_count
      t.integer :group_size
      t.integer :pickup_address_id
      t.integer :dropoff_address_id
      t.references :mobility
      t.references :funding_source
      t.string :trip_purpose
      t.string :trip_result
      t.string :notes
      t.decimal :donation, :precision=>10, :scale=>2
      t.datetime :trip_confirmed
    end
  end

  def self.down
  end
end
