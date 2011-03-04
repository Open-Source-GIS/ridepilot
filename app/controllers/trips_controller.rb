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
    @client = Client.find(params[:client_id])
    authorize! :read, @client
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  def edit
    @client = @trip.client
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all

  end

  def create
    trip_params = params[:trip]

    client = Client.find(trip_params[:client_id])
    authorize! :read, client

    provider = client.provider
    authorize! :manage, provider
    trip_params[:provider_id] = client.provider.id

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
    client = Client.find(trip_params[:client_id])
    provider = client.provider
    authorize! :manage, provider
    trip_params[:provider_id] = client.provider.id

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
