require 'open-uri'

class AddressesController < ApplicationController

  def geocode_address
    address = Address.new(params[:address])

    url = "http://open.mapquestapi.com/nominatim/v1/search?format=json&q=" + CGI.escape(address.text)
    
    result = OpenURI.open_uri(url)

    render :text=>result   
  end

end
