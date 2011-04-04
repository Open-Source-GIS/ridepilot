class Address < ActiveRecord::Base
  belongs_to :provider

  normalize_attribute :name, :with=> [:squish, :titleize]
  normalize_attribute :building_name, :with=> [:squish, :titleize]
  normalize_attribute :address, :with=> [:squish, :titleize]
  normalize_attribute :city, :with=> [:squish, :titleize]

  def compute_in_trimet_district
    return Region.count(:conditions => ["name='TriMet' and st_contains(the_geom, ?)", the_geom]) > 0

  end

  def latitude
    return the_geom.x
  end

  def longitude
    return the_geom.y
  end

  def latitude=(x)
    the_geom.x = x
  end

  def longitude=(y)
    the_geom.y = y
  end

  def text
    if building_name and name
      first_line = "%s - %s\n" % [name, building_name]
    elsif building_name
      first_line = building_name + "\n"
    elsif name
      first_line = name + "\n"
    end

    return first_line + "%s\n%s, %s  %s" % [address, city, state, zip]

  end
end
