class Customer < ActiveRecord::Base
  belongs_to :provider
  belongs_to :address
  belongs_to :mobility
  belongs_to :created_by, :foreign_key => :created_by_id, :class_name=>'User'
  belongs_to :updated_by, :foreign_key => :updated_by_id, :class_name=>'User'
  accepts_nested_attributes_for :address

  normalize_attribute :first_name, :with=> [:squish, :titleize]
  normalize_attribute :last_name, :with=> [:squish, :titleize]
  normalize_attribute :middle_initial, :with=> [:squish, :upcase]

  default_scope :order => 'last_name, first_name, middle_initial'

  stampable :creator_attribute => :created_by_id, :updater_attribute => :updated_by_id

  def name
    if group
      return "(Group) %s" % first_name
    end
    if middle_initial.present?
      return "%s %s. %s" % [first_name, middle_initial, last_name]
    else
      return "%s %s " % [first_name, last_name]
    end
  end

  def age_in_years
    if birth_year.nil?
      return nil
    end
    today = Date.today
    years = today.year - birth_date.year #2011 - 1980 = 31
    if today.month < birth_year.month  || today.month == birth_year.month and today.day < birth_year.day #but 4/8 is before 7/3, so age is 30
      years -= 1
    end
    return years
  end
  
  def as_autocomplete
    { :label           => name, 
      :id              => id,
      :phone_number_1  => phone_number_1, 
      :phone_number_2  => phone_number_2,
      :mobility_notes  => mobility_notes,
      :private_notes   => private_notes,
      :group           => group
    }
  end

end
