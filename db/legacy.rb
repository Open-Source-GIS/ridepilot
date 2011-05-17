require 'csv'

ETHNICITIES = {'W' => 'Caucasian','B' => 'African American','A' => 'Asian','I' => 'Asian Indian','C' => 'Chinese','F' => 'Filipino','J' => 'Japanese','K' => 'Korean','V' => 'Vietnamese','P' => 'Pacific Islander','N' => 'American Indian/Alaska Native','X' => 'Native Hawaiian','G' => 'Guamanian or Chamorrow','S' => 'Samoan','R' => 'Russian','U' => 'Unknown','R' => 'Refused','O' => 'Other'}

CSV.foreach(File.join(Rails.root,'tblClient.txt'),headers: true) do |r|
  c = Customer.find_or_initialize_by_id(r['ClientID'])
  c.first_name = r['FirstName']
  c.last_name = r['LastName']
  c.phone_number_1 = r['Phone']
  c.ethnicity = ETHNICITIES[r['Race']]
  #c.created_at = r['Created']
  #c.updated_at = r['LastChanged']
  c.inactivated_date = Date.today if r['Gone']=1 
  c.private_notes = r['Comment']
  c.save!
end

c_id = Customer.maximum(:id)
ActiveRecord::Base.connection.execute("SELECT setval('customers_id_seq',#{c_id})")
