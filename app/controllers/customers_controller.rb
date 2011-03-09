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
LOWER(last_name || ', ' || first_name) LIKE ? ", query, query, query, query]) \
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
  end

  def create

    @customer = Customer.new(params[:customer])
    @customer.provider = current_user.current_provider

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
