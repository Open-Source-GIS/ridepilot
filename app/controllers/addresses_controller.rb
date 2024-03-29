require 'open-uri'

class AddressesController < ApplicationController
  load_and_authorize_resource
    
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

    addresses = Address.accessible_by(current_ability).where(["((LOWER(address) like '%' || ? || '%' ) and  (city || ', ' || state || ' ' || zip like ? || '%')) or LOWER(building_name) like '%' || ? || '%' or LOWER(name) like '%' || ? || '%' ", address, city_state_zip, term, term]).where(:provider_id => current_provider_id, :inactive => false)

    if addresses.size > 0
      #there are some existing addresses
      address_json = addresses.map { |address| address.json }
      
      address_json << Address::NewAddressOption unless request.env["HTTP_REFERER"].match(/addresses\/[0-9]+\/edit/)
            
      render :json => address_json
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
      address_json = addresses.map { |address| 
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

      }
      
      address_json << Address::NewAddressOption unless request.env["HTTP_REFERER"].match(/addresses\/[0-9]+\/edit/)
            
      render :json => address_json
    end
  end

  def create
    authorize! :new, Address
    
    the_geom       = params[:lat].to_s.size > 0 ? Point.from_x_y(params[:lon].to_f, params[:lat].to_f, 4326) : nil
    prefix         = params['prefix']
    address_params = {}
    
    for param in ['name', 'building_name', 'address', 'city', 'state', 'zip', 'phone_number', 'in_district', 'default_trip_purpose']
      address_params[param] = params[prefix + "_" + param]
    end
    
    address_params[:provider_id] = current_provider_id
    address_params[:the_geom]    = the_geom
    
    address = Address.new(address_params)
    
    if address.save
      address_json = {'id' => address.id, 'label' => address.text}
      address_json.merge!( 'phone_number' => address.phone_number, 'trip_purpose' => address.default_trip_purpose ) if prefix == "dropoff"
      render :json => address_json
    else
      errors = address.errors.clone
      errors['prefix'] = prefix
      render :json => errors
    end
  end
  
  def search
    @term      = params[:name].downcase
    @provider  = Provider.find params[:provider_id]
    @addresses = Address.accessible_by(current_ability).for_provider(@provider).search_for_term(@term)
    
    respond_to do |format|
      format.json { render :text => render_to_string(:partial => "results.html") }
    end
  end
  
  def update
    if @address.update_attributes params[:address]
      flash[:notice] = "Address '#{@address.name}' was successfully updated"
      redirect_to provider_path(@address.provider)
    else
      render :action => :edit
    end
  end
  
  def destroy
    if @address.trips.present?
      if new_address = @address.replace_with!(params[:address_id])
        redirect_to new_address.provider, :notice => "#Address was successfully replaced with #{new_address.name}."
      else
        redirect_to edit_address_path(@address), :notice => "#{@address.name} can't be deleted without associating trips with another address."
      end
    else
      @address.destroy
      redirect_to current_provider, :notice => "#{@address.name} was successfully deleted."
    end
  end

end
