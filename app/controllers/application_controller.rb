class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :get_providers
  include Userstamp

  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403.html", :status => 403
  end

  def get_providers
    if !current_user
      return
    end

    ride_connection = Provider.find_by_name("Ride Connection")
    @provider_map = {}
    for role in current_user.roles
      if role.provider == ride_connection 
        @provider_map = Provider.all.collect {|provider| [ provider.name, provider.id ] }
        break
      end
      @provider_map[role.provider_id] = role.provider.name
    end
  end

  def test_exception_notification
    raise 'Testing, 1 2 3.'
  end

  private
  def current_provider_id
    return current_user.current_provider_id
  end

  def current_provider
    return current_user.current_provider
  end
end
