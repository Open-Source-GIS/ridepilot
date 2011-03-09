class Ability
  include CanCan::Ability

  def initialize(user)
    ride_connection = Provider.find_by_name("Ride Connection")

    for role in user.roles
      if role.provider == ride_connection 
        if role.admin
          can :read, :all 
          can :manage, :all 
        end
      else
        if role.admin
          action = :manage
        else
          action = :view
        end
        can action, Trip, :provider_id => provider.id
        can action, Run, :provider_id => provider.id
        can action, Driver, :provider_id => provider.id
        can action, Vehicle, :provider_id => provider.id
        can action, User, {:role => {:provider_id => provider.id}}
        can action, Monthly, :provider_id => provider.id
        can action, Address, :provider_id => provider.id
        can action, Customer, :provider_id => provider.id
        can action, RepeatingTrip, :provider_id => provider.id
      end
    end

    can :read, Mobility
    can :read, Region
  end
end
