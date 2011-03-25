class Driver < ActiveRecord::Base
  belongs_to :provider

  def name
    return "%s %s" % [first_name, last_name]
  end

end
