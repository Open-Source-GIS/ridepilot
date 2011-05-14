require 'csv'

CSV.foreach(File.join(Rails.root,'tblClient.txt'),headers: true) do |r|
  Customer.find_or_initialize_by_id(r['id'])
end
