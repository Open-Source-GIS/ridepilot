class Ability
  include CanCan::Ability

  def initialize(user)
    ride_connection = Provider.find_by_name("Ride Connection")
    can_manage_all = false

    can :read, Mobility
    can :read, Region

    for role in user.roles
      if role.provider == ride_connection 
        if role.admin?
          can_manage_all = true
        else
          can :read, :all 
        end
      else
        if role.editor?
          action = :manage
        else
          action = :read
        end
        can action, Provider, :id => role.provider.id
        cannot :create, Provider
      end
    end
    can :manage, :all if can_manage_all

    provider = user.current_provider
    role = Role.find(:first, :conditions=>["provider_id=? and user_id=?", provider.id, user.id])
    if not role
      return
    end
    if role.editor?
      action = :manage
    else
      action = [:read, :search]
    end

    can action, Trip, :provider_id => provider.id if provider.scheduling?
    can action, Run, :provider_id => provider.id if provider.scheduling?
    can action, Driver, :provider_id => provider.id
    can action, Vehicle, :provider_id => provider.id
    can action, VehicleMaintenanceEvent, :provider_id => provider.id
    can action, Monthly, :provider_id => provider.id
    can action, Address, :provider_id => provider.id
    can action, Customer, :provider_id => provider.id
    can action, RepeatingTrip, :provider_id => provider.id
    can :read, FundingSource, {:providers => {:id => provider.id}}
        
    can action, DevicePool, :provider_id => provider.id if provider.dispatch?
    can action, DevicePool, :provider_id => provider.id if provider.dispatch?
        
    can action, DevicePoolDriver do |device_pool_driver|
      device_pool_driver.provider_id == provider.id
    end
    
    can :manage, DevicePoolDriver do |device_pool_driver|
      device_pool_driver.driver_id == user.driver.id if user.driver
    end

    if role.admin?
      can :manage, User, {:roles => {:provider_id => provider.id}}
    else
      can :read, User, {:roles => {:provider_id => provider.id}}
    end

  end
end
