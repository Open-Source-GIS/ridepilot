require 'fixjour'
require 'faker'

Fixjour :verify => false do
  define_builder(Provider) do |klass, overrides|
    klass.new({
      :name => Faker::Lorem.words(2),
      :logo_file_name => Faker::Internet.domain_name
    })
  end
  
  define_builder(Role) do |klass, overrides|
    user = overrides[:user] || new_user
    klass.new({
      :user => user,
      :provider => user.current_provider,
      :level => 100
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
end