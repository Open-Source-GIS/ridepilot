class TripsController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
  end

  def trips_requiring_callback
    #The trip coordinatior has made decisions on whether to confirm or
    #turn down trips.  Now they want to call back the customer to tell
    #them what's happened.  This is a list of all customers who have
    #not been marked as informed, ordered by when they were last
    #called.

    @trips = Trip.accessible_by(current_ability).where(["trip_result = 'turndown' or trip_result = 'confirmed' and customer_informed = false and pickup_time >= ? ", Date.today]).order("called_back_at")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @trips }
    end
  end

  def unscheduled
    #The trip coordinatior wants to confirm or turn down individual
    #trips.  T his is a list of all trips that haven't been decided
    #on yet.

    @trips = Trip.accessible_by(current_ability).where(["trip_result = 'unscheduled' and pickup_time >= ? ", Date.today]).order("pickup_time")
  end


  def reached
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.called_back_at = Time.now
      @trip.customer_informed = true
      @trip.save
    end
    redirect_to :action=>:trips_requiring_callback
  end

  def unreached
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.called_back_at = Time.now
      @trip.customer_informed = false
      @trip.save
    end
    redirect_to :action=>:trips_requiring_callback
  end

  def confirm
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.trip_result = "confirmed"
      @trip.save
    end
    redirect_to :action=>:unscheduled
  end

  def turndown
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.trip_result = "turndown"
      @trip.save
    end
    redirect_to :action=>:unscheduled
  end



  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  def new
    @trip = Trip.new
    @customer = Customer.find(params[:customer_id])
    authorize! :read, @customer
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  def edit
    @customer = @trip.customer
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all

  end

  def create
    trip_params = params[:trip]

    customer = Customer.find(trip_params[:customer_id])
    authorize! :read, customer

    provider = customer.provider
    authorize! :manage, provider
    trip_params[:provider_id] = customer.provider.id

    @trip = Trip.new(trip_params)

    respond_to do |format|
      if @trip.save
        format.html { redirect_to(@trip, :notice => 'Trip was successfully created.') }
        format.xml  { render :xml => @trip, :status => :created, :location => @trip }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    trip_params = params[:trip]
    customer = Customer.find(trip_params[:customer_id])
    provider = customer.provider
    authorize! :manage, provider
    trip_params[:provider_id] = customer.provider.id

    respond_to do |format|
      if @trip.update_attributes(trip_params)
        format.html { redirect_to(@trip, :notice => 'Trip was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy

    respond_to do |format|
      format.html { redirect_to(trips_url) }
      format.xml  { head :ok }
    end
  end
end
