class Address < ActiveRecord::Base
  belongs_to :provider
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'

  normalize_attribute :name, :with=> [:squish, :titleize]
  normalize_attribute :building_name, :with=> [:squish, :titleize]
  normalize_attribute :address, :with=> [:squish, :titleize]
  normalize_attribute :city, :with=> [:squish, :titleize]

  validates :address, :length => { :minimum => 5 }
  validates :city,    :length => { :minimum => 2 }
  validates :state,   :length => { :is => 2 }
  validates :zip,     :length => { :is => 5, :if => lambda { |a| a.zip.present? } }
  
  before_validation :compute_in_trimet_district

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id
  
  NewAddressOption = { :label => "New Address", :id => 0 }

  scope :for_provider, lambda {|provider| where(:provider_id => provider.id)}
  scope :search_for_term, lambda {|term| where("LOWER(name) LIKE '%' || :term || '%' OR LOWER(building_name) LIKE '%' || :term || '%' OR LOWER(address) LIKE '%' || :term || '%'",{:term => term})}

  scope :for_provider, lambda {|provider| where(:provider_id => provider.id)}
  scope :search_for_term, lambda {|term| where("LOWER(name) LIKE '%' || :term || '%' OR LOWER(building_name) LIKE '%' || :term || '%' OR LOWER(address) LIKE '%' || :term || '%'",{:term => term})}

  def compute_in_trimet_district
    if the_geom and in_district.nil?
      in_district = Region.count(:conditions => ["name='TriMet' and st_contains(the_geom, ?)", the_geom]) > 0
    end 
  end

  def latitude
    if the_geom
      return the_geom.x
    else
      return nil
    end
  end

  def longitude
    if the_geom
      return the_geom.y
    else
      return nil
    end
  end

  def latitude=(x)
    the_geom.x = x
  end

  def longitude=(y)
    the_geom.y = y
  end

  def text
    if building_name.to_s.size > 0 and name.to_s.size > 0
      first_line = "%s - %s\n" % [name, building_name]
    elsif building_name.to_s.size > 0
      first_line = building_name + "\n"
    elsif name.to_s.size > 0
      first_line = name + "\n"
    else
      first_line = ''
    end

    return ("%s %s \n%s, %s  %s" % [first_line, address, city, state, zip]).strip

  end

  def json
    {
      :label => text, 
      :id => id, 
      :name => name,
      :building_name => building_name,
      :address => address,
      :city => city,
      :state => state,
      :zip => zip,
      :in_district => in_district,
      :phone_number => phone_number,
      :lat => latitude,
      :lon => longitude,
      :default_trip_purpose => default_trip_purpose
    }
  end

end
