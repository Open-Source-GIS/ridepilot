class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  before_filter :get_providers

  def get_providers
    if !current_user
      return
    end

    ride_connection = Provider.find_by_name("Ride Connection")
    @providers = {}
    for role in current_user.roles
      if role.provider == ride_connection 
        @providers = Role.all.collect {|role| [ role.provider.name, role.provider_id ] }
        break
      end
      @providers[role.provider_id] = role.provider.name
    end

  end

end
