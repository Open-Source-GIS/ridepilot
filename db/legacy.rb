require 'csv'
require 'legacy_helper'

ETHNICITIES = {'W' => 'Caucasian','B' => 'African American','A' => 'Asian','I' => 'Asian Indian','C' => 'Chinese','F' => 'Filipino','J' => 'Japanese','K' => 'Korean','V' => 'Vietnamese','P' => 'Pacific Islander','N' => 'American Indian/Alaska Native','X' => 'Native Hawaiian','G' => 'Guamanian or Chamorrow','S' => 'Samoan','R' => 'Russian','U' => 'Unknown','R' => 'Refused','O' => 'Other'}
TRIP_REASONS = {'MED' => 'Medical','LIFE' => 'Life-sustaining Medical','PER' => 'Personal/Support Services','SHOP' => 'Shopping','WORK' => 'School/Work','VOL' => 'Volunteer Work','REC' => 'Recreation','NUT' => 'Nutrition'}

p = Provider.find_or_initialize_by_name('Northwest Pilot Project')
p.save(:validate => false) if p.new_record?

m = Mobility.find_by_name("Unknown")  

#if false
puts 'Addresses:'
CSV.foreach(File.join(Rails.root,'db','legacy','tblDestination.txt'),headers: true) do |r|
  a = Address.find_or_initialize_by_id(r['DestinationID'])
  a.address = clean_address(r['Location'])
  a.address = '_____' if a.address.nil?
  a.building_name = r['PlaceName']
  a.city = 'Portland'
  a.state = 'OR'
  a.zip = '97201' if a.address == '1430 SW Broadway'
  a.provider = p
  a.save! 
  puts a.id if a.id.modulo(100) == 0
end
ActiveRecord::Base.connection.execute("SELECT setval('addresses_id_seq',#{Address.maximum(:id)})")

puts 'Customers:'
CSV.foreach(File.join(Rails.root,'db','legacy','tblClient.txt'),headers: true) do |r|
  unless r['FirstName'].blank? && r['LastName'].blank?
    c = Customer.find_or_initialize_by_id(r['ClientID'])
    c.first_name = r['FirstName']
    c.last_name = r['LastName']
    c.phone_number_1 = r['Phone']
    c.ethnicity = ETHNICITIES[r['Race']]
    c.created_at = r['Created']
    c.updated_at = r['LastChanged']
    if r['Gone'] == '1'
      c.inactivated_date = Date.today
    else
      c.inactivated_date = nil
    end
    c.private_notes = r['Comment']
    c.provider = p
    c.mobility = m
    if !r['Address'].blank?
      # puts "[#{r['Address']}]"
      addr = clean_address(r['Address'])
      if addr == '1430 SW Broadway' 
        zip = '97201'
      else
        if !r['ZipCode'].blank? 
          zip = r['ZipCode'][0..4] if r['ZipCode'].size >= 5
        else
          zip = nil
        end
      end

      a = Address.find_or_initialize_by_address(addr)
      a.city = 'Portland'
      a.state = 'OR'
      a.zip = zip
      a.save!
      c.address = a
    end
    c.save!
    puts c.id if c.id.modulo(100) == 0
  end
end
ActiveRecord::Base.connection.execute("SELECT setval('customers_id_seq',#{Customer.maximum(:id)})")

puts 'Trips:'
CSV.foreach(File.join(Rails.root,'db','legacy','tblRide.txt'),headers: true) do |r|
  if Customer.exists?(r['ClientID'])
    t = Trip.find_or_initialize_by_id(r['RideID'])
    t.customer_id = r['ClientID']
    #puts r['Pickup'], r['Appointment']
    t.pickup_time = fix_up_date(r['Pickup'])
    t.appointment_time = fix_up_date(r['Appointment'])
    t.provider = p
    t.mobility = m 

    unless r['DriverCode'].blank? 
      driver = Driver.find_or_initialize_by_name(r['DriverCode']) 
      driver.provider = p
      driver.save!
    end
    
    if r['Cab'] = 0 
      run = Run.find_or_initialize_by_date_and_driver_id(t.pickup_time.to_date, driver.nil? ? nil : driver.id)
      run.scheduled_start_time = t.pickup_time if run.scheduled_start_time.nil? || run.scheduled_start_time > t.pickup_time
      run.actual_start_time = t.pickup_time if run.actual_start_time.nil? || run.actual_start_time > t.pickup_time
      run.scheduled_end_time = t.appointment_time if run.scheduled_end_time.nil? || run.scheduled_end_time < t.appointment_time
      run.actual_end_time = t.appointment_time if run.actual_end_time.nil? || run.actual_end_time < t.appointment_time
      run.provider = p
      run.driver = driver
      run.save!
      t.run = run
    end
    
    t.trip_purpose = TRIP_REASONS[r['ReasonCode']]
    pu_addr = clean_address(r['PickupAt'])
    a = Address.find_or_initialize_by_address(pu_addr)
    if a.new_record?
      a.city = 'Portland'
      a.state = 'OR'
      a.save!
    end
    t.pickup_address = a
    t.dropoff_address_id = r['DestinationID']
    t.save!
    puts t.id if t.id.modulo(100) == 0
  end
end
ActiveRecord::Base.connection.execute("SELECT setval('trips_id_seq',#{Trip.maximum(:id)})")
#end

puts 'Vehicles:'
CSV.foreach(File.join(Rails.root,'db','legacy','tblVehicle.txt'),headers: true) do |r|
  v = Vehicle.find_or_initialize_by_id(r['VehicleID'])
  v.name = r['VehicleName']
  v.year = r['YearMakeModel'].split(' ')[0].to_i unless r['YearMakeModel'].blank?
  v.make = r['YearMakeModel'].split(' ')[1] unless r['YearMakeModel'].blank?
  v.model = r['YearMakeModel'].split(' ')[2..-1].join(' ') unless r['YearMakeModel'].blank?
  v.vin = r['VIN']
  v.license_plate = r['LicensePlate']
  v.garaged_location = r['ParkedLocation']
  v.provider = p
  v.save!
  puts v.id
end
ActiveRecord::Base.connection.execute("SELECT setval('vehicles_id_seq',#{Vehicle.maximum(:id)})")

puts 'Vehicle Maintenance'
CSV.foreach(File.join(Rails.root,'db','legacy','tblVehicleMaintenance.txt'),headers: true) do |r|
  if r['ServicePerformed'].present?
    vm = VehicleMaintenanceEvent.find_or_initialize_by_id(r['ID'])
    vm.vehicle_id = r['VehicleID']
    vm.provider = p
    vm.reimbursable = true
    vm.service_date = fix_up_date(r['ServiceDate'])
    vm.invoice_date = fix_up_date(r['InvoiceDate'])
    vm.services_performed = r['ServicePerformed']
    vm.odometer = r['OdometerReading']
    vm.vendor_name = r['Vendor']
    vm.invoice_number = r['InvoiceNumber']
    vm.invoice_amount = r['InvoiceAmount']
    vm.save!
    puts vm.id
  end
end
ActiveRecord::Base.connection.execute("SELECT setval('vehicle_maintenance_events_id_seq',#{VehicleMaintenanceEvent.maximum(:id)})")
