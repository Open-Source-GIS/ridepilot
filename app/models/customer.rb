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
    if address.present?
      address_text = address.text 
      address_id = address.id 
    end

    { :label           => name, 
      :id              => id,
      :phone_number_1  => phone_number_1, 
      :phone_number_2  => phone_number_2,
      :mobility_notes  => mobility_notes,
      :address         => address_text,
      :address_id      => address_id,
      :private_notes   => private_notes,
      :group           => group
    }
  end

  def self.by_term( term, limit = nil )
    if term[0].match /\d/ #by phone number
      query = term.gsub("-", "")
      query = query[1..-1] if query.start_with? "1"
      return Customer.where([
"regexp_replace(phone_number_1, '[^0-9]', '') = ? or
regexp_replace(phone_number_2, '[^0-9]', '') = ?
", query, query])
    else
      if term.match /^[a-z]+$/i
        #a single word, either a first or a last name
        query, args = make_customer_name_query("first_name", term)
        lnquery, lnargs = make_customer_name_query("last_name", term)
        query += " or " + lnquery
        args += lnargs
      elsif term.match /^[a-z]+[ ,]\s*$/i
        comma = term.index(",")
        #a single word, either a first or a last name, complete
        term.gsub!(",", "")
        term = term.strip
        if comma
          query, args = make_customer_name_query("last_name", term, :complete)
        else
          query, args = make_customer_name_query("first_name", term, :complete)
        end
      elsif term.match /^[a-z]+\s+[a-z]$/i
        #a first name followed by either a middle initial or the first
        #letter of a last name

        first_name, last_name = term.split(" ").map(&:strip)

        query, args = make_customer_name_query("first_name", first_name, :complete)
        lnquery, lnargs = make_customer_name_query("last_name", last_name)
        miquery, miargs = make_customer_name_query("middle_initial", last_name, :initial)

        query += " and (" + lnquery +  " or " + miquery + ")"
        args += lnargs + miargs

      elsif term.match /^[a-z]+\s+[a-z]{2,}$/i
        #a first name followed by two or more letters of a last name

        first_name, last_name = term.split(" ").map(&:strip)

        query, args = make_customer_name_query("first_name", first_name, :complete)
        lnquery, lnargs = make_customer_name_query("last_name", last_name)
        query += " and " + lnquery
        args += lnargs
      elsif term.match /^[a-z]+\s*,\s*[a-z]+$/i
        #a last name, a comma, some or all of a first name

        last_name, first_name = term.split(",").map(&:strip)

        query, args = make_customer_name_query("last_name", last_name, :complete)
        fnquery, fnargs = make_customer_name_query("first_name", first_name)
        query += " and " + fnquery
        args += fnargs
      elsif term.match /^[a-z]+\s+[a-z][.]?\s+[a-z]+$/i
        #a first name, middle initial, some or all of a last name

        first_name, middle_initial, last_name = term.split(" ").map(&:strip)

        middle_initial = middle_initial[0]

        query, args = make_customer_name_query("first_name", first_name, :complete)
        miquery, miargs = make_customer_name_query("middle_initial", middle_initial, :initial)

        lnquery, lnargs = make_customer_name_query("last_name", last_name)
        query += " and " + miquery + " and " + lnquery
        args += miargs + lnargs
      elsif term.match /^[a-z]+\s*,\s*[a-z]+\s+[a-z][.]?$/i
        #a last name, a comma, a first name, a middle initial

        last_name, first_and_middle = term.split(",").map(&:strip)
        first_name, middle_initial = first_and_middle.split(" ").map(&:strip)
        middle_initial = middle_initial[0]

        query, args = make_customer_name_query("first_name", first_name, :complete)
        miquery, miargs = make_customer_name_query("middle_initial", middle_initial, :initial)
        lnquery, lnargs = make_customer_name_query("last_name", last_name, :complete)
        query += " and " + miquery + " and " + lnquery
        args += miargs + lnargs
      end

      conditions = [query] + args
      customers  = where(conditions)

      limit ? customers.limit(limit) : customers
    end
  end

  def self.make_customer_name_query(field, value, option=nil)
    value = value.downcase
    if option == :initial
      return "(LOWER(%s) = ?)" % field, [value]
    elsif option == :complete
      return "(LOWER(%s) = ? or
dmetaphone(%s) = dmetaphone(?) or
dmetaphone(%s) = dmetaphone_alt(?)  or
dmetaphone_alt(%s) = dmetaphone(?) or
dmetaphone_alt(%s) = dmetaphone_alt(?))" % [field, field, field, field, field], [value, value, value, value, value]
    else
      like = value + "%"

      return "(LOWER(%s) like ? or
dmetaphone(%s) LIKE dmetaphone(?) || '%%' or
dmetaphone(%s) LIKE dmetaphone_alt(?)  || '%%' or
dmetaphone_alt(%s) LIKE dmetaphone(?)  || '%%'or
dmetaphone_alt(%s) LIKE dmetaphone_alt(?) || '%%')" % [field, field, field, field, field], [like, value, value, value, value]

    end
  end

end
