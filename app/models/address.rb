class Address < ActiveRecord::Base
  belongs_to :provider

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
end
