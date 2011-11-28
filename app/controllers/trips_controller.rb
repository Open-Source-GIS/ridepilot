class TripsController < ApplicationController
  load_and_authorize_resource
  
  before_filter :set_calendar_week_start, :only => [:index, :new, :edit]

  def index
    @trips = @trips.for_provider(current_provider_id).includes(:customer)
    
    respond_to do |format|
      format.html do
        @start = params[:start].to_i
        # let js handle grabbing the trips
        @trips = [] 
        @vehicles = Vehicle.accessible_by(current_ability).where(:provider_id => current_provider_id)
      end
      format.xml  { render :xml => @trips }
      format.json { render :json => trips_json }
    end
  end

  def trips_requiring_callback
    #The trip coordinator has made decisions on whether to confirm or
    #turn down trips.  Now they want to call back the customer to tell
    #them what's happened.  This is a list of all customers who have
    #not been marked as informed, ordered by when they were last
    #called.

    @trips = Trip.accessible_by(current_ability).for_provider(current_provider_id).where(
      ["customer_informed = false and pickup_time >= ? ", Date.today]).order("called_back_at")

    respond_to do |format|
      format.html
      format.xml  { render :xml => @trips }
    end
  end

  def unscheduled
    #The trip coordinatior wants to confirm or turn down individual
    #trips.  This is a list of all trips that haven't been decided
    #on yet.

    @trips = Trip.accessible_by(current_ability).for_provider(current_provider_id).where(
      ["trip_result = '' and pickup_time >= ? ", Date.today]).order("pickup_time")
  end

  def reconcile_cab
    #the cab company has sent a log of all trips in the past [time period]
    #we want to mark some trips as no-shows.  This will be a paginated
    #list of trips
    @trips = Trip.accessible_by(current_ability).for_provider(current_provider_id).where(
      "cab = true and (trip_result = 'COMP' or trip_result = 'NS')").reorder("pickup_time desc").paginate :page=>params[:page], :per_page=>50
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
      @trip.called_back_by = current_user
      @trip.customer_informed = true
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

  def new
    @trip = Trip.new(:provider_id=>current_provider_id, :customer_id=>params[:customer_id])
    @trip.mobility_id = Customer.find(params[:customer_id]).mobility_id if params[:customer_id]
    prep_view
    @trips = []

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
    prep_edit
    @trips = []
    
    respond_to do |format|
      format.html 
      format.js  { @remote = true; render :json => {:form => render_to_string(:partial => 'form') }, :content_type => "text/json" }
    end
  end

  def create
    trip_params = params[:trip]

    @customer = Customer.find(trip_params[:customer_id])
    authorize! :read, @customer

    provider = @customer.provider
    trip_params[:provider_id] = @customer.provider.id if @customer.provider.present?
    handle_trip_params trip_params

    authorize! :manage, Trip.new(trip_params)

    if is_repeating_trip params
      #this is a repeating trip, so we need to create both
      #the repeating trip, and the instance for today
      repeating_trip_params = extract_repeating_trip_params trip_params
      repeating_trip = RepeatingTrip.create(repeating_trip_params)
      repeating_trip.instantiate
      trip_params[:repeating_trip_id] = repeating_trip.id
      trip_params.delete :schedule_attributes

      @trip = Trip.new(trip_params)
      if @trip.save
        redirect_to(trips_path(:start => @trip.pickup_time.to_i), :notice => 'Trip was successfully created.') 
      else
        prep_view
        @schedule = repeating_trip.schedule_attributes
        render :action => "new" 
      end
    else
      @trip = Trip.new(trip_params)
      if @trip.save
        redirect_to(trips_path(:start => @trip.pickup_time.to_i), :notice => 'Trip was successfully created.') 
      else
        prep_view
        repeating_trip = RepeatingTrip.new
        repeating_trip.schedule_attributes = {:repeat => 1, :interval => 1, :start_date => Time.now.to_s, :interval_unit=>"week"}
        @schedule = repeating_trip.schedule_attributes
        render :action => "new" 
      end
    end
  end

  def update
    trip_params = params[:trip]
    @customer = Customer.find(trip_params[:customer_id])
    provider = @customer.provider
    trip_params[:provider_id] = @customer.provider.id if @customer.provider.present?
    handle_trip_params trip_params
    authorize! :manage, @trip

    if is_repeating_trip params
      #this is a repeating trip, so we need to edit both
      #the repeating trip, and the instance for today
      repeating_trip_params = extract_repeating_trip_params trip_params
      if not @trip.repeating_trip
        @trip.repeating_trip = RepeatingTrip.new
      end

      repeating_trip = @trip.repeating_trip.update_attributes(repeating_trip_params)
      @trip.repeating_trip.instantiate
      trip_params.delete :schedule_attributes
    elsif !is_repeating_trip params and @trip.repeating_trip
      #This is a trip that was repeating, but the repetition needs to be cleared.
      #We want to detach this trip and all past trips from the repeating trip record,
      #delete all future instances that have been created, and delete the repeating trip
      rt = @trip.repeating_trip
      if @trip.pickup_time < Time.now #Be sure not delete trips that have already happened.
        Trip.repeating_based_on(rt).today_and_prior.update_all 'repeating_trip_id = NULL'
        Trip.repeating_based_on(rt).after_today.destroy_all
      else 
        Trip.repeating_based_on(rt).prior_to(@trip.pickup_time).update_all 'repeating_trip_id = NULL'
        Trip.repeating_based_on(rt).after(@trip.pickup_time).destroy_all
      end
      @trip.repeating_trip_id = nil
      rt.destroy 
    end
    
    respond_to do |format|
      if @trip.update_attributes(trip_params)
        format.html { redirect_to(trips_path, :notice => 'Trip was successfully updated.')  }
        format.js { 
          render :json => {:status => "success"}, :content_type => "text/json"
        }
      else
        prep_edit
        format.html { render :action => "edit"  }
        format.js   { @remote = true; render :json => {:form => render_to_string(:partial => 'form') }, :content_type => "text/json" }
      end
    end

  end

  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy

    respond_to do |format|
      format.html { redirect_to(trips_url) }
      format.xml  { head :ok }
      format.js   { render :json => {:status => "success"}, :content_type => "text/json" }
    end
  end

  private
  
  def set_calendar_week_start
    @week_start = if params[:start].present?
      Time.at params[:start].to_i/1000
    elsif @trip.try :pickup_time
      @trip.pickup_time.beginning_of_week
    else
      Time.now.beginning_of_week
    end
  end
  
  def trips_json
    filter_trips
    trips = @trips.map { |trip| 
      { :id    => trip.id,
        :start => trip.pickup_time.to_s(:no_tz),
        :end   => trip.appointment_time.to_s(:no_tz),
        :title => trip.customer.name
      }
    }

    days = @trips.group_by(&:date)
    rows = []
    days.each do |day, trips|
      rows << render_to_string(:partial => "day_row.html", :locals => { :day => day })
      trips.each do |trip|
        rows << render_to_string(:partial => "trip_row.html", :locals => { :trip => trip })
      end
    end

    {:events => trips, :rows => rows }    
  end

  def prep_view
    authorize! :read, @trip
    @customer        = @trip.customer
    @mobilities      = Mobility.order(:name).all
    @funding_sources = FundingSource.all
    @vehicles        = Vehicle.active.for_provider(@trip.provider_id) 
    @trip_results    = TRIP_RESULT_CODES.map { |k,v| [v,k] }
    @trip_purposes   = TRIP_PURPOSES
    @drivers         = Driver.active.for_provider @trip.provider_id
    @trips           = [] if @trips.nil?

    @trip.run_id = -1 if @trip.cab
    cab_run = Run.new :cab => true
    cab_run.id = -1
    @runs = Run.for_provider(@trip.provider_id).incomplete_on(@trip.pickup_time.try(:to_date)) << cab_run
  end
  
  def prep_edit
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

  def handle_trip_params(trip_params)
    if trip_params[:run_id] == '-1' 
      #cab trip
      trip_params[:run_id] = nil
      trip_params[:cab] = true
    else
      trip_params[:cab] = false
    end

    if trip_params[:customer_informed] and not @trip.customer_informed
      trip_params[:called_back_by] = current_user
      trip_params[:called_back_at] = DateTime.now.to_s
    end
  end

  def is_repeating_trip(params)

    return (params[:interval].size > 0 and (params[:monday] or 
                                           params[:tuesday] or 
                                           params[:wednesday] or 
                                           params[:thursday] or 
                                           params[:friday] or 
                                           params[:saturday] or 
                                           params[:sunday]))
  end

  def extract_repeating_trip_params(trip_params)

    repeating_trip_params = trip_params.clone
    repeating_trip_params.delete :in_district
    repeating_trip_params.delete :called_back_by
    repeating_trip_params.delete :called_back_at
    repeating_trip_params.delete :cab
    repeating_trip_params.delete :cab_notified
    repeating_trip_params.delete :trip_result
    repeating_trip_params.delete :vehicle_id
    repeating_trip_params.delete :driver_id
    repeating_trip_params.delete :donation
    repeating_trip_params.delete :customer_informed
    repeating_trip_params.delete :called_back_at
    repeating_trip_params.delete :called_back_by
    repeating_trip_params.delete :run_id
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
    return repeating_trip_params
  end

  def filter_trips
    if params[:end].present? && params[:start].present?
      t_start = Time.at params[:start].to_i
      t_end   = Time.at params[:end].to_i
    else
      time    = Time.now
      t_start = time.beginning_of_week
      t_end   = t_start + 6.days
    end

    @trips = @trips.
      where("pickup_time >= '#{t_start.strftime "%Y-%m-%d %H:%M:%S"}'").
      where("pickup_time <= '#{t_end.strftime "%Y-%m-%d %H:%M:%S"}'")
      
    if params[:vehicle_id].present?  
      @trips = @trips.select {|t| t.vehicle_id == params[:vehicle_id].to_i } 
    end
  end
end
