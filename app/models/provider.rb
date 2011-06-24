class Provider < ActiveRecord::Base
  has_many :roles
  has_many :users, :through=>:roles
  has_many :drivers
  has_many :vehicles
  has_many :monthlies
  has_many :funding_source_visibilities
  has_many :funding_sources, :through=>:funding_source_visibilities
  has_many :addresses

  has_attached_file :logo, :styles => { :small => "150x150>" }

  validates_length_of :name, :minimum => 2

  validates_attachment_presence :logo
  validates_attachment_size :logo, :less_than => 200.kilobytes
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png', 'image/gif']
end
