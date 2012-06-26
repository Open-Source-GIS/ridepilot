class Driver < ActiveRecord::Base
  belongs_to :provider
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'
  belongs_to :user
  
  has_one :device_pool_driver
  has_one :device_pool, :through => :device_pool_driver
  
  validates :user_id, :uniqueness => {:allow_nil => true}
  
  validates_uniqueness_of :name, :scope => :provider_id
  validates_length_of :name, :minimum=>2

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
  
  scope :users,         where("drivers.user_id IS NOT NULL")
  scope :active,        where(:active => true)
  scope :for_provider,  lambda { |provider_id| where(:provider_id => provider_id) }
  scope :default_order, order(:name)
  
  def self.unassigned(provider)
    users.for_provider(provider).reject { |driver| driver.device_pool.present? }
  end
  
end
