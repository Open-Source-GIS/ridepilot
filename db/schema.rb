# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20120613052228) do

  create_table "addresses", :force => true do |t|
    t.string   "name"
    t.string   "building_name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.boolean  "in_district"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",                        :default => 0
    t.point    "the_geom",             :limit => nil,                    :srid => 4326
    t.string   "phone_number"
    t.boolean  "inactive",                            :default => false
    t.string   "default_trip_purpose"
  end

  add_index "addresses", ["the_geom"], :name => "index_addresses_on_the_geom", :spatial => true

  create_table "customers", :force => true do |t|
    t.string   "first_name"
    t.string   "middle_initial"
    t.string   "last_name"
    t.string   "phone_number_1"
    t.string   "phone_number_2"
    t.integer  "address_id"
    t.string   "email"
    t.date     "activated_date"
    t.date     "inactivated_date"
    t.string   "inactivated_reason"
    t.date     "birth_date"
    t.integer  "mobility_id"
    t.text     "mobility_notes"
    t.string   "ethnicity"
    t.text     "emergency_contact_notes"
    t.text     "private_notes"
    t.text     "public_notes"
    t.integer  "provider_id"
    t.boolean  "group",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",            :default => 0
  end

  create_table "device_pool_drivers", :force => true do |t|
    t.string   "status"
    t.float    "lat"
    t.float    "lng"
    t.integer  "device_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "driver_id"
    t.datetime "posted_at"
    t.integer  "vehicle_id"
  end

  add_index "device_pool_drivers", ["device_pool_id"], :name => "index_devices_on_device_pool_id"
  add_index "device_pool_drivers", ["driver_id"], :name => "index_device_pool_users_on_user_id"

  create_table "device_pools", :force => true do |t|
    t.integer  "provider_id"
    t.string   "name"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drivers", :force => true do |t|
    t.boolean  "active"
    t.boolean  "paid"
    t.integer  "provider_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",  :default => 0
    t.integer  "user_id"
  end

  create_table "funding_source_visibilities", :force => true do |t|
    t.integer "funding_source_id"
    t.integer "provider_id"
  end

  create_table "funding_sources", :force => true do |t|
    t.string "name"
  end

  create_table "mobilities", :force => true do |t|
    t.string "name"
  end

  create_table "monthlies", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "volunteer_escort_hours"
    t.integer  "volunteer_admin_hours"
    t.integer  "provider_id"
    t.integer  "complaints"
    t.integer  "compliments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",           :default => 0
  end

  create_table "providers", :force => true do |t|
    t.string   "name"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "dispatch"
    t.boolean  "scheduling"
  end

  create_table "regions", :force => true do |t|
    t.string  "name"
    t.polygon "the_geom", :limit => nil, :srid => 4326
  end

  add_index "regions", ["the_geom"], :name => "index_regions_on_the_geom", :spatial => true

  create_table "repeating_trips", :force => true do |t|
    t.text     "schedule_yaml"
    t.integer  "provider_id"
    t.integer  "customer_id"
    t.datetime "pickup_time"
    t.datetime "appointment_time"
    t.integer  "guest_count",        :default => 0
    t.integer  "attendant_count",    :default => 0
    t.integer  "group_size",         :default => 0
    t.integer  "pickup_address_id"
    t.integer  "dropoff_address_id"
    t.integer  "mobility_id"
    t.integer  "funding_source_id"
    t.string   "trip_purpose"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",       :default => 0
    t.boolean  "round_trip"
    t.integer  "driver_id"
    t.integer  "vehicle_id"
    t.boolean  "cab",                :default => false
    t.boolean  "customer_informed"
  end

  create_table "roles", :force => true do |t|
    t.integer "user_id"
    t.integer "provider_id"
    t.integer "level"
  end

  create_table "runs", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.integer  "start_odometer"
    t.integer  "end_odometer"
    t.datetime "scheduled_start_time"
    t.datetime "scheduled_end_time"
    t.integer  "unpaid_driver_break_time"
    t.integer  "vehicle_id"
    t.integer  "driver_id"
    t.boolean  "paid"
    t.boolean  "complete"
    t.integer  "provider_id"
    t.datetime "actual_start_time"
    t.datetime "actual_end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",             :default => 0
  end

  add_index "runs", ["provider_id", "date"], :name => "index_runs_on_provider_id_and_date"
  add_index "runs", ["provider_id", "scheduled_start_time"], :name => "index_runs_on_provider_id_and_start_time"

  create_table "travel_time_estimates", :id => false, :force => true do |t|
    t.integer "from_address_id"
    t.integer "to_address_id"
    t.integer "seconds"
  end

  create_table "trips", :force => true do |t|
    t.integer  "run_id"
    t.integer  "customer_id"
    t.datetime "pickup_time"
    t.datetime "appointment_time"
    t.integer  "guest_count",                                       :default => 0
    t.integer  "attendant_count",                                   :default => 0
    t.integer  "group_size",                                        :default => 0
    t.integer  "pickup_address_id"
    t.integer  "dropoff_address_id"
    t.integer  "mobility_id"
    t.integer  "funding_source_id"
    t.string   "trip_purpose"
    t.string   "trip_result",                                       :default => ""
    t.text     "notes"
    t.decimal  "donation",           :precision => 10, :scale => 2, :default => 0.0
    t.integer  "provider_id"
    t.datetime "called_back_at"
    t.boolean  "customer_informed",                                 :default => false
    t.integer  "repeating_trip_id"
    t.boolean  "cab",                                               :default => false
    t.boolean  "cab_notified",                                      :default => false
    t.text     "guests"
    t.boolean  "in_district"
    t.integer  "called_back_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",                                      :default => 0
    t.boolean  "round_trip"
  end

  add_index "trips", ["provider_id", "appointment_time"], :name => "index_trips_on_provider_id_and_appointment_time"
  add_index "trips", ["provider_id", "pickup_time"], :name => "index_trips_on_provider_id_and_pickup_time"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_provider_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vehicle_maintenance_events", :force => true do |t|
    t.integer  "vehicle_id",                                                       :null => false
    t.integer  "provider_id",                                                      :null => false
    t.boolean  "reimbursable"
    t.date     "service_date"
    t.date     "invoice_date"
    t.text     "services_performed"
    t.decimal  "odometer",           :precision => 10, :scale => 1
    t.string   "vendor_name"
    t.string   "invoice_number"
    t.decimal  "invoice_amount",     :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",                                      :default => 0
  end

  create_table "vehicles", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.string   "make"
    t.string   "model"
    t.string   "license_plate"
    t.string   "vin"
    t.string   "garaged_location"
    t.integer  "provider_id"
    t.boolean  "active",            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "lock_version",      :default => 0
    t.integer  "default_driver_id"
  end

end
