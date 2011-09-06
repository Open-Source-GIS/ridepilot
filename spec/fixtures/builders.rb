require 'fixjour'
require 'faker'

Fixjour :verify => false do
  define_builder(Provider) do |klass, overrides|
    klass.new({
      :name           => Faker::Lorem.words(2),
      :logo_file_name => Faker::Internet.domain_name
    })
  end
  
  define_builder(Role) do |klass, overrides|
    user = overrides[:user] || create_user
    
    klass.new({
      :user     => user,
      :provider => user.current_provider,
      :level    => 100
    })
  end
  
  define_builder(User) do |klass, overrides|
    user = klass.new({
      :email                 => Faker::Internet.email,
      :password              => 'password',
      :password_confirmation => 'password'
    })
    
    user.current_provider = overrides[:current_provider] || new_provider
    
    user
  end  
  
  define_builder(Driver) do |klass, overrides|
    klass.new({
      :name     => Faker::Lorem.words(2), 
      :provider => new_provider, 
      :user     => new_user
    })
  end
  
  define_builder(DevicePool) do |klass, overrides|
    klass.new({
      :name     => Faker::Company.name,
      :color    => ActiveSupport::SecureRandom.hex(3),
      :provider => new_provider
    })
  end
  
  define_builder(DevicePoolDriver) do |klass, overrides|
    dpd             = klass.new({})
    
    dpd.driver      = overrides[:driver] || new_driver
    dpd.device_pool = overrides[:device_pool] || new_device_pool
    dpd
  end

  define_builder(Trip) do |klass, overrides|
    pickup_time      = overrides[:pickup_time]      || Time.now + 1.week
    appointment_time = overrides[:appointment_time] || pickup_time + 30.minutes
    
    klass.new({
      :pickup_address   => new_address,
      :dropoff_address  => new_address,
      :pickup_time      => pickup_time,
      :appointment_time => appointment_time,
      :trip_purpose     => 'Medical',
      :customer         => create_customer
    })
  end
  
  define_builder(Address) do |klass, overrides|
    klass.new({
      :address => Faker::Address.street_address, 
      :city => Faker::Address.city, 
      :state => "OR"
    })
  end
  
  define_builder(Customer) do |klass, overrides|
    klass.new({
      :first_name => Faker::Name.first_name,
      :last_name  => Faker::Name.last_name,
      :provider   => create_provider
    })
  end
end