class CustomersController < ApplicationController
  load_and_authorize_resource :except=>[:autocomplete, :found]

  def search
  end

  def autocomplete
    term = params['term'].downcase
    limit = 10
    if term[0].match /\d/ 
      #by phone number
      query = term.gsub("-", "")
      if query.start_with? "1"
        query = query[1..-1]
      end
      customers = Customer.accessible_by(current_ability).where([
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
      customers = Customer.accessible_by(current_ability).where(conditions).limit(limit)
    end
    
    render :json => customers.map { |customer| customer.as_autocomplete }
  end

  def found
    if params[:commit].starts_with? "New trip"
      redirect_to new_trip_path :customer_id=>params[:customer_id]
    else
      redirect_to customer_path params[:customer_id]
    end
  end

  def index #only active customers
    @show_inactivated_date = false
    @customers = @customers.where(:inactivated_date => nil)
    respond_to do |format|
      format.html { @customers = @customers.paginate :page => params[:page], :per_page => PER_PAGE }
      format.xml  { render :xml => @customers }
    end
  end

  def all
    @show_inactivated_date = true
    @customers = Customer.accessible_by(current_ability)
    @customers = @customers.paginate :page => params[:page], :per_page => PER_PAGE
    render :action=>"index"
  end


  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  def new
    @customer = Customer.new name_options
    @customer.address ||= Address.new
    @mobilities = Mobility.all
    @ethnicities = ETHNICITIES

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  def edit
    @customer = Customer.find(params[:id])
    @mobilities = Mobility.all
    @ethnicities = ETHNICITIES
  end

  def create

    @customer = Customer.new(params[:customer])
    @customer.provider = current_provider
    @customer.activated_date = Date.today

    if params[:ignore_dups] != "1"
      #check for duplicates
      #similar-sounding first/last names and (no or matching) middle initial

      first_name = @customer.first_name
      middle_initial = @customer.middle_initial
      last_name = @customer.last_name
      dup_customers = Customer.accessible_by(current_ability).where([
"(middle_initial = ? or middle_initial = '' or ? = '') and 

(dmetaphone(last_name) = dmetaphone(?) or
 dmetaphone(last_name) = dmetaphone_alt(?) or 
 dmetaphone_alt(last_name) = dmetaphone(?) or 
 dmetaphone_alt(last_name) = dmetaphone_alt(?)) and

(dmetaphone_alt(first_name) = dmetaphone_alt(?) or
 dmetaphone_alt(first_name) = dmetaphone(?) or
 dmetaphone(first_name) = dmetaphone(?)  or
 dmetaphone(first_name) = dmetaphone_alt(?)) or
(email = ? and email !=  '' and email is not null and ? != '')
", 
middle_initial, middle_initial, 
last_name, last_name, last_name, last_name, 
first_name, first_name, first_name, first_name,
@customer.email, @customer.email]).limit(1)

      if dup_customers.size > 0
        dup = dup_customers[0]
        flash[:alert] = "There is already a customer with a similar name or the same email address: <a href=\"#{url_for :action=>:show, :id=>dup.id}\">#{dup.name}</a> (dob #{dup.birth_date}).  If this is truly a different customer, check the 'ignore duplicates' box to continue creating this customer.".html_safe
        @dup = true
        @mobilities = Mobility.all
        @ethnicities = ETHNICITIES
        return render :action=>"new"
      end
    end

    respond_to do |format|
      if @customer.save
        format.html { redirect_to(@customer, :notice => 'Customer was successfully created.') }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def inactivate
    @customer = Customer.find(params[:customer_id])
    authorize! :edit, @customer

    @customer.inactivated_date = Date.today
    @customer.inactivated_reason = params[:customer][:inactivated_reason]
    @customer.save
    redirect_to :action=>:index
  end

  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        format.html { redirect_to(@customer, :notice => 'Customer was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end

  def make_customer_name_query(field, value, option=nil)
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

  def name_options
    if params[:customer_name]
      parts = params[:customer_name].split " "
      atts  = { :first_name => parts.first }

      case parts.length
      when 2
        atts[:last_name]      = parts.last
      else
        atts[:middle_initial] = parts[1]
        atts[:last_name]      = parts[2, parts.length - 2].join " "
      end if parts.length > 1

      atts
    end
  end

end
