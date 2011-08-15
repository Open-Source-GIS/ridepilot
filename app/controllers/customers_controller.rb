class CustomersController < ApplicationController
  load_and_authorize_resource :except=>[:autocomplete, :found]

  def autocomplete
    customers = Customer.by_term( params['term'].downcase, 10 ).accessible_by(current_ability)
    
    render :json => customers.map { |customer| customer.as_autocomplete }
  end

  def found
    if params[:customer_id].blank?
      redirect_to search_customers_path( :term => params[:customer_name] )
    elsif params[:commit].downcase.starts_with? "new trip"
      redirect_to new_trip_path :customer_id=>params[:customer_id]
    else
      redirect_to customer_path params[:customer_id]
    end
  end

  def index #only active customers
    @show_inactivated_date = false
    @customers = @customers.where(:inactivated_date => nil)
    @customers = @customers.by_letter(params[:letter]) if params[:letter].present?
    
    respond_to do |format|
      format.html { @customers = @customers.paginate :page => params[:page], :per_page => PER_PAGE }
      format.xml  { render :xml => @customers }
    end
  end
  
  def search
    @customers = Customer.by_term( params[:term].downcase ).
      accessible_by( current_ability ).
      paginate( :page => params[:page], :per_page => PER_PAGE )
      
    render :action => :index
  end

  def all
    @show_inactivated_date = true
    @customers = Customer.accessible_by(current_ability)
    @customers = @customers.paginate :page => params[:page], :per_page => PER_PAGE
    render :action=>"index"
  end


  def show
    @customer = Customer.find(params[:id])

    # default scope is pickup time ascending, so reverse
    @trips    = @customer.trips.reverse.paginate :page => params[:page], :per_page => PER_PAGE

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  def new
    @customer = Customer.new name_options
    @customer.address ||= @customer.build_address :provider => current_provider
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
        @mobilities  = Mobility.all
        @ethnicities = ETHNICITIES
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
    if @customer.trips.present?
      if new_customer = @customer.replace_with!(params[:customer_id])
        redirect_to new_customer, :notice => "#{@customer.name} was successfully deleted."
      else
        render :action => :show, :id => @customer.id, :error => "Customer could not be deleted."
      end
    else
      @customer.destroy
      redirect_to customers_url, :notice => "#{@customer.name} was successfully deleted."
    end
  end
  
  private

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
    end || {}
  end

end
