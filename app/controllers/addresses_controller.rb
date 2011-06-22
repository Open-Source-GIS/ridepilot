require 'open-uri'

class AddressesController < ApplicationController

  def autocomplete
    term = params['term'].downcase.strip

    #clean up address
    term.gsub!(' apt ', ' #')
    term.gsub!(' apartment ', ' #')
    term.gsub!(' suite ', ' #')

    term.gsub!(' n ', ' north ')
    term.gsub!(' ne ', ' northeast ')
    term.gsub!(' e ', ' east ')
    term.gsub!(' se ', ' southeast ')
    term.gsub!(' s ', ' south ')
    term.gsub!(' sw ', ' southwest ')
    term.gsub!(' w ', ' west ')
    term.gsub!(' nw ', ' northwest ')

    term.gsub!(' ave,', 'avenue,')
    term.gsub!(' dr,', 'drive,')
    term.gsub!(' st,', 'street,')
    term.gsub!(' blvd,', 'boulevard,')
    term.gsub!(' pkwy,', 'parkway,')

    #three ways to match: 
    #- name
    #- building name
    #- substring of textified address (split at comma into address, 
    #  city/state/zip)

    address, city_state_zip = term.split(",")
    address.strip!
    if city_state_zip
      city_state_zip.strip!
    else
      city_state_zip = ''
    end

    addresses = Address.accessible_by(current_ability).where(["((LOWER(address) like '%' || ? || '%' ) and  (city || ', ' || state || ' ' || zip like ? || '%')) or LOWER(building_name) like '%' || ? || '%' or LOWER(name) like '%' || ? || '%' ", address, city_state_zip, term, term])

    if addresses.size > 0
      #there are some existing addresses
      render :json => addresses.map { |address| address.json } << Address::NewAddressOption
    else
      #no existing addresses, try geocoding

      term.gsub!(","," ") #nominatim hates commas

      if term.size < 5 or ! term.match /[a-z]{2}/
        #do not geocode too-short terms
        return render :json => [Address::NewAddressOption] 
      end
      url = "http://open.mapquestapi.com/nominatim/v1/search?format=json&addressdetails=1&countrycodes=us&q=" + CGI.escape(term)
    
      result = OpenURI.open_uri(url)

      addresses = ActiveSupport::JSON.decode(result)

      #only addresses within one decimal degree of the trimet district
      addresses = addresses.find_all { |address|
        point = Point.from_x_y(address['lon'].to_f, address['lat'].to_f, 4326)
        Region.count(:conditions => ["name='TriMet' and st_distance(the_geom, ?) <= 1", point]) > 0 
      }
      
      #now, convert addresses to local json format
      render :json => addresses.map { |address| 
        #todo: apt numbers
        address = address['address']
        street_address = '%s %s' % [address['house_number'], address['road']]
        address_obj = Address.new( 
                    :name => '',
                    :building_name => '',
                    :address => street_address,
                    :city => address['city'],
                    :state => STATE_NAME_TO_POSTAL_ABBREVIATION[address['state'].upcase],
                    :zip => address['postcode'],
                    :the_geom => Point.from_x_y(address['lon'].to_f, address['lat'].to_f, 4326)
                    )
        address_obj.json

      } << Address::NewAddressOption
    end
  end

  def find_or_create
  end

  def create
    authorize! :new, Address
    
    the_geom       = params[:lat].to_s.size > 0 ? Point.from_x_y(params[:lon].to_f, params[:lat].to_f, 4326) : nil
    prefix         = params['prefix']
    address_params = {}
    
    for param in ['name', 'building_name', 'address', 'city', 'state', 'zip', 'phone_number']
      address_params[param] = params[prefix + "_" + param]
    end
    
    address_params[:provider_id] = current_provider_id
    address_params[:the_geom]    = the_geom
    
    address = Address.new(address_params)
    
    if address.save
      address_json = {'id' => address.id, 'label' => address.text}
      address_json.merge!( 'phone_number' => address.phone_number ) if prefix == "dropoff"
      render :json => address_json
    else
      errors = address.errors.clone
      errors['prefix'] = prefix
      render :json => errors
    end

  end

end
