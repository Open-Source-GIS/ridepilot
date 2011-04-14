class CustomersController < ApplicationController
  load_and_authorize_resource

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
      query = "%#{term.downcase}%"
      customers = Customer.accessible_by(current_ability).where([
"LOWER(first_name || ' ' || middle_initial || ' ' || last_name) LIKE ? or 
LOWER(last_name) LIKE ? or 
LOWER(first_name) LIKE ? or
LOWER(last_name || ', ' || first_name) LIKE ? or
dmetaphone(last_name) LIKE dmetaphone(?) || '%'  or 
dmetaphone(first_name) LIKE dmetaphone(?) || '%'  or
dmetaphone(last_name) LIKE dmetaphone_alt(?) || '%'  or 
dmetaphone(first_name) LIKE dmetaphone_alt(?) || '%'  or
dmetaphone_alt(last_name) LIKE dmetaphone(?) || '%'  or 
dmetaphone_alt(first_name) LIKE dmetaphone(?) || '%'  or
dmetaphone_alt(last_name) LIKE dmetaphone_alt(?) || '%'  or 
dmetaphone_alt(first_name) LIKE dmetaphone_alt(?) || '%' 
", query, query, query, query, term, term, term, term, term, term, term, term])
    .limit(limit)
    end
    
    render :json => customers.map { |customer| {:label=>customer.name, :id=>customer.id}}
  end

  def found
    if params[:commit].starts_with? "New trip"
      redirect_to new_trip_path :customer_id=>params[:customer_id]
    else
      redirect_to customer_path params[:customer_id]
    end
  end

  def index
    @customers = Customer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end

  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  def new
    @customer = Customer.new
    @customer.address ||= Address.new
    @mobilities = Mobility.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  def edit
    @customer = Customer.find(params[:id])
    @mobilities = Mobility.all
  end

  def create

    @customer = Customer.new(params[:customer])
    @customer.provider = current_user.current_provider
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
email = ?
", 
middle_initial, middle_initial, 
last_name, last_name, last_name, last_name, 
first_name, first_name, first_name, first_name,
@customer.email]).limit(1)

      if dup_customers.size > 0
        dup = dup_customers[0]
        flash[:notice] = "There is already a customer with a similar name: <a href=\"#{url_for :action=>:show, :id=>dup.id}\">#{dup.name}</a> (dob #{dup.birth_date}).  If this is truly a different customer, check the 'ignore duplicates' box to continue creating this customer.".html_safe
        @dup = true
        @mobilities = Mobility.all
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
end
