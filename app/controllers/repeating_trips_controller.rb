class RepeatingTripsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
    @repeating_trip = RepeatingTrip.new

    #FIXME: this doesn't actually work for some reason -- the schedule
    #attributes in the form are all empty. 
    @repeating_trip.schedule_attributes = {:repeat => 1, :interval => 1, :start_date => Time.now.to_s, :interval_unit=>"day"}
    @customer = Customer.find(params[:customer_id])
    authorize! :read, @customer
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all

  end


  def show
  end

  def create
    repeating_trip_params = params[:repeating_trip]

    customer = Customer.find(repeating_trip_params[:customer_id])
    authorize! :read, customer

    provider = customer.provider
    authorize! :manage, provider
    repeating_trip_params[:provider_id] = provider.id

    @repeating_trip = RepeatingTrip.new(repeating_trip_params)
    @repeating_trip.schedule_attributes = params[:repeating_trip][:schedule_attributes]

    if @repeating_trip.save
      redirect_to(@repeating_trip, :notice => 'Repeating trip was successfully created.') 
    else
      render :action => "new" 
    end
  end

  def edit
    @customer = @repeating_trip.customer
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all

  end

  def update
    repeating_trip_params = params[:repeating_trip]
    customer = Customer.find(repeating_trip_params[:customer_id])
    provider = customer.provider
    authorize! :manage, provider
    repeating_trip_params[:provider_id] = customer.provider.id

    if @repeating_trip.update_attributes(repeating_trip_params)
      redirect_to(@repeating_trip, :notice => 'Repeating trip was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy

    @repeating_trip.destroy

    respond_to do |format|
      format.html { redirect_to(repeating_trips_url) }
      format.xml  { head :ok }
    end
  end


end
