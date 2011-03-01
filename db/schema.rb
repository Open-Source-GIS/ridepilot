# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110301215657) do

  create_table "addresses", :force => true do |t|
    t.string  "name"
    t.string  "building_name"
    t.string  "address"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.boolean "in_district"
  end

  create_table "client", :force => true do |t|
    t.string  "first_name"
    t.string  "middle_initial"
    t.string  "last_name"
    t.string  "phone_number_1"
    t.string  "phone_number_2"
    t.integer "address_id"
    t.string  "email"
    t.date    "activated_date"
    t.date    "inactivated_date"
    t.string  "inactivated_reason"
    t.date    "birth_date"
    t.integer "mobility_id"
    t.string  "mobility_notes"
    t.string  "ethnicity"
    t.string  "emergency_contact_notes"
    t.string  "private_notes"
    t.string  "public_notes"
  end

  create_table "driver", :force => true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.boolean "active"
    t.boolean "paid"
  end

  create_table "funding_sources", :force => true do |t|
    t.string "name"
  end

  create_table "mobilities", :force => true do |t|
    t.string "name"
  end

  create_table "runs", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.integer  "start_odometer"
    t.integer  "end_odometer"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "unpaid_driver_break_time"
    t.integer  "vehicle_id"
    t.integer  "driver_id"
    t.boolean  "paid"
    t.boolean  "complete"
  end

  create_table "trips", :force => true do |t|
    t.integer  "run_id"
    t.integer  "client_id"
    t.datetime "pickup_time"
    t.datetime "appointment_time"
    t.integer  "guest_count"
    t.integer  "attendant_count"
    t.integer  "group_size"
    t.integer  "pickup_address_id"
    t.integer  "dropoff_address_id"
    t.integer  "mobility_id"
    t.integer  "funding_source_id"
    t.string   "trip_purpose"
    t.string   "trip_result"
    t.string   "notes"
    t.decimal  "donation",           :precision => 10, :scale => 2
    t.datetime "trip_confirmed"
  end

  create_table "vehicles", :force => true do |t|
    t.string  "name"
    t.integer "year"
    t.string  "make"
    t.string  "model"
    t.string  "license_plate"
    t.string  "vin"
    t.string  "garaged_location"
  end

end
