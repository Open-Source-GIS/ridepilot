class TripsController < ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
      format.json { 
        trips = @trips.map { |trip| 
          {:id => trip.id,
           :start=> trip.pickup_time,
           :end=> trip.appointment_time,
           :title => trip.customer.name
          }
        }
        json = ActiveSupport::JSON.encode trips
        render :text => json 
      }
    end
  end

  def trips_requiring_callback
    #The trip coordinator has made decisions on whether to confirm or
    #turn down trips.  Now they want to call back the customer to tell
    #them what's happened.  This is a list of all customers who have
    #not been marked as informed, ordered by when they were last
    #called.

    @trips = Trip.accessible_by(current_ability).where(["trip_result = 'TD' or trip_result = 'COMP' and customer_informed = false and pickup_time >= ? ", Date.today]).order("called_back_at")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @trips }
    end
  end

  def unscheduled
    #The trip coordinatior wants to confirm or turn down individual
    #trips.  This is a list of all trips that haven't been decided
    #on yet.

    @trips = Trip.accessible_by(current_ability).where(["trip_result = 'unscheduled' and pickup_time >= ? ", Date.today]).order("pickup_time")
  end

  def reconcile_cab
    #the cab company has sent a log of all trips in the past [time period]
    #we want to mark some trips as no-shows.  This will be a paginated
    #list of trips
    @trips = Trip.accessible_by(current_ability).where("cab = true and (trip_result = 'COMP' or trip_result = 'NS')").reorder("pickup_time desc").paginate :page=>params[:page], :per_page=>50
  end

  def no_show
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.trip_result = 'NS'
      @trip.save
    end
    redirect_to :action=>:reconcile_cab, :page=>params[:page]
  end

  def send_to_cab
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.cab = true
      @trip.cab_informed = false
      @trip.trip_result = 'COMP'
      @trip.save
    end
    redirect_to :action=>:reconcile_cab, :page=>params[:page]
  end

  def reached
    #mark the user as having been informed that their trip has been
    #approved or turned down
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.called_back_at = Time.now
      @trip.called_back_by = current_user.id
      @trip.customer_informed = true
      @trip.save
    end
    redirect_to :action=>:trips_requiring_callback
  end

  def unreached
    #note that we have called the user to approve or turn down their trip
    #but did not reach them
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.called_back_at = Time.now
      @trip.called_back_by = current_user.id
      @trip.customer_informed = false
      @trip.save
    end
    redirect_to :action=>:trips_requiring_callback
  end

  def confirm
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.trip_result = "COMP"
      @trip.save
    end
    redirect_to :action=>:unscheduled
  end

  def turndown
    @trip = Trip.find(params[:trip_id])
    if can? :edit, @trip
      @trip.trip_result = "TD"
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
    prep_view

    #we only use this to get access to the schedule attributes
    repeating_trip = RepeatingTrip.new
    repeating_trip.schedule_attributes = {:repeat => 1, :interval => 1, :start_date => Time.now.to_s, :interval_unit=>"week"}
    @schedule = repeating_trip.schedule_attributes

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  def edit
    prep_view
    if @trip.repeating_trip
      repeating_trip = @trip.repeating_trip
    else
      #we only use this to get access to the schedule attributes
      repeating_trip = RepeatingTrip.new
      repeating_trip.schedule_attributes = {:repeat => 1, :interval => 1, :start_date => Time.now.to_s, :interval_unit=>"week"}
    end
    @schedule = repeating_trip.schedule_attributes
  end

  def create
    trip_params = params[:trip]

    @customer = Customer.find(trip_params[:customer_id])
    authorize! :read, @customer

    provider = @customer.provider
    authorize! :manage, provider
    trip_params[:provider_id] = @customer.provider.id

    handle_cab trip_params

    if params[:interval].size > 0 and (params[:monday] or 
                                       params[:tuesday] or 
                                       params[:wednesday] or 
                                       params[:thursday] or 
                                       params[:friday] or 
                                       params[:saturday] or 
                                       params[:sunday])
      #this is a repeating trip, so we need to create both
      #the repeating trip, and the instance for this week

      repeating_trip_params = trip_params.clone
      repeating_trip_params.delete :in_district
      repeating_trip_params.delete :called_back_by
      repeating_trip_params.delete :called_back_at
      repeating_trip_params.delete :cab
      repeating_trip_params.delete :cab_notified
      repeating_trip_params.delete :trip_result
      repeating_trip_params.delete :vehicle_id
      repeating_trip_params.delete :donation
      repeating_trip_params[:schedule_attributes] = { 
        :repeat => 1,
        :interval_unit => "week", 
        :start_date => DateTime.parse(trip_params[:pickup_time]).to_date.to_s,
        :interval => params[:interval], 
        :monday => params[:monday] ? 1 : 0,
        :tuesday => params[:tuesday] ? 1 : 0,
        :wednesday => params[:wednesday] ? 1 : 0,
        :thursday => params[:thursday] ? 1 : 0,
        :friday => params[:friday] ? 1 : 0,
        :saturday => params[:saturday] ? 1 : 0,
        :sunday => params[:sunday] ? 1 : 0
      }

      repeating_trip = RepeatingTrip.create(repeating_trip_params)
      trip_params[:repeating_trip_id] = repeating_trip.id
      trip_params.delete :schedule_attributes

      @trip = Trip.new(trip_params)
      if @trip.save
        redirect_to(@trip, :notice => 'Trip was successfully created.') 
      else
          new 
          render :action => "new" 
      end
    else
      @trip = Trip.new(trip_params)
      if @trip.save
        redirect_to(@trip, :notice => 'Trip was successfully created.') 
      else
          new 
          render :action => "new" 
      end
    end
  end

  def update
    trip_params = params[:trip]
    @customer = Customer.find(trip_params[:customer_id])
    provider = @customer.provider
    authorize! :manage, provider
    trip_params[:provider_id] = @customer.provider.id
    handle_cab trip_params
    respond_to do |format|
      if @trip.update_attributes(trip_params)
        format.html { redirect_to(@trip, :notice => 'Trip was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { 
          edit
          render :action => "edit" 
        }
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

  private

  def prep_view
    @trip = Trip.new(:provider_id=>current_provider_id)
    @customer = Customer.find(params[:customer_id])
    authorize! :read, @customer
    @mobilities = Mobility.all
    @funding_sources = FundingSource.all
    @drivers = Driver.where(:provider_id=>@trip.provider_id)
    cab_vehicle = Vehicle.new(:name=>"cab", :id=>-1)
    @vehicles = Vehicle.active.where(:provider_id=>@trip.provider_id) + [cab_vehicle]
    @trip_results = TRIP_RESULT_CODES
    @trip_purposes = TRIP_PURPOSES

  end

  def handle_cab(trip_params)
    if trip_params[:vehicle_id] == '-1' or trip_params[:vehicle_id] == ''
      #cab trip
      trip_params[:vehicle_id] = 0
      trip_params[:cab] = true
    end
  end
end
