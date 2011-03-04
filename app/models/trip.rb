class Trip < ActiveRecord::Base
  belongs_to :provider
  belongs_to :run

  validates :provider_id, :provider => true

end
