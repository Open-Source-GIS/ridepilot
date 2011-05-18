require 'csv'
require 'legacy_helper'

ETHNICITIES = {'W' => 'Caucasian','B' => 'African American','A' => 'Asian','I' => 'Asian Indian','C' => 'Chinese','F' => 'Filipino','J' => 'Japanese','K' => 'Korean','V' => 'Vietnamese','P' => 'Pacific Islander','N' => 'American Indian/Alaska Native','X' => 'Native Hawaiian','G' => 'Guamanian or Chamorrow','S' => 'Samoan','R' => 'Russian','U' => 'Unknown','R' => 'Refused','O' => 'Other'}

CSV.foreach(File.join(Rails.root,'tblDestination.txt'),headers: true) do |r|
  a = Address.find_or_initialize_by_id(r['DestinationID'])
  a.address = clean_address(r['Location'])
  a.building_name = r['PlaceName']
  a.city = 'Portland'
  a.state = 'OR'
  a.zip = '97201' if addr == '1430 SW Broadway'
  a.save!
end

CSV.foreach(File.join(Rails.root,'tblClient.txt'),headers: true) do |r|
  unless r['FirstName'].blank? && r['LastName'].blank?
    c = Customer.find_or_initialize_by_id(r['ClientID'])
    c.first_name = r['FirstName']
    c.last_name = r['LastName']
    c.phone_number_1 = r['Phone']
    c.ethnicity = ETHNICITIES[r['Race']]
    c.created_at = r['Created']
    c.updated_at = r['LastChanged']
    c.inactivated_date = Date.today if r['Gone']=1 
    c.private_notes = r['Comment']
    if !r['Address'].blank?
      # puts "[#{r['Address']}]"
      addr = clean_address(r['Address'])
      if addr = '1430 SW Broadway' 
        zip = '97201'
      else
        if !r['ZipCode'].blank? 
          zip = r['ZipCode'][0..4] if r['ZipCode'].size >= 5
        else
          zip = nil
        end
      end
      addr = addr + ("_" * (5 - addr.size)) if addr.size < 5

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

last_customer_id = Customer.maximum(:id)
ActiveRecord::Base.connection.execute("SELECT setval('customers_id_seq',#{last_customer_id})")

CSV.foreach(File.join(Rails.root,'tblRide.txt'),headers: true) do |r|
end
