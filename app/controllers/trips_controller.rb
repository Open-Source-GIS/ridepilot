class TripsController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
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
