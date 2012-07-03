class Query
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :start_date
  attr_accessor :before_end_date
  attr_accessor :end_date
  attr_accessor :vehicle_id
  attr_accessor :driver_id
  attr_accessor :trip_display

  def convert_date(obj, base)
    return Date.new(obj["#{base}(1i)"].to_i,obj["#{base}(2i)"].to_i,(obj["#{base}(3i)"] || 1).to_i)
  end

  def initialize(params = {})
    now = Date.today
    @start_date = params[:start_date] || Date.new(now.year, now.month, 1).prev_month
    if params[:before_end_date]
      @before_end_date = params[:before_end_date].to_date
      @end_date = params[:before_end_date].to_date + 1
    elsif params[:end_date]
      @before_end_date = params[:end_date].to_date - 1
      @end_date = params[:end_date].to_date
    else
      @before_end_date = start_date.next_month - 1
      @end_date = start_date.next_month
    end
    if params.present?
      if params["start_date(1i)"]
        @start_date = convert_date(params, :start_date)
      end
      if params["before_end_date(1i)"]
        @before_end_date = convert_date(params, :before_end_date)
        @end_date = @before_end_date + 1
      elsif params["end_date(1i)"]
        @end_date = convert_date(params, :end_date)
        @before_end_date = @end_date - 1
      end
      if params["vehicle_id"]
        @vehicle_id = params["vehicle_id"].to_i
      end
      if params["driver_id"]
        @driver_id = params["driver_id"].to_i
      end
      if params["trip_display"]
        @trip_display = params["trip_display"]
      end
    end
  end

  def persisted?
    false
  end

end

def bind(args)
  return ActiveRecord::Base.__send__(:sanitize_sql_for_conditions, args, '')
end

class ReportsController < ApplicationController

  def index
    @driver_query = Query.new :start_date => Date.today, :end_date => Date.today
    @trips_query = Query.new 
    cab = Driver.new(:name=>"Cab")
    cab.id = -1
    all = Driver.new(:name=>"All")
    all.id = -2
    drivers = Driver.active.for_provider(current_provider).default_order.accessible_by(current_ability)
    @drivers =  [all] + drivers
    @drivers_with_cab =  [all, cab] + drivers
  end

  def vehicles_monthly
    query_params = params[:query] || {}
    @query = Query.new(query_params)
    @start_date = @query.start_date
    @end_date = @query.end_date
    @vehicles = Vehicle.reportable.active.for_provider(current_provider).accessible_by(current_ability)
    @provider = current_provider

    @total_hours = {}
    @total_rides = {}
    @beginning_odometer = {}
    @ending_odometer = {}

    @vehicles.each do |vehicle|
      month_runs = Run.for_vehicle(vehicle.id).for_date_range(@start_date, @end_date)
      month_trips = Trip.for_vehicle(vehicle.id).for_date_range(@start_date, @end_date).completed

      @total_hours[vehicle] = month_runs.sum("actual_end_time - actual_start_time").to_i 
      @total_rides[vehicle] = month_trips.sum("(CASE WHEN round_trip THEN 2 ELSE 1 END) * (1 + guest_count + attendant_count + group_size)").to_i

      @beginning_odometer[vehicle] = month_runs.minimum(:start_odometer) || -1
      @ending_odometer[vehicle] = month_runs.maximum(:end_odometer) || -1
    end
  end

  def service_summary
    query_params = params[:query] || {}
    @query = Query.new(query_params)
    @start_date = @query.start_date
    @end_date = @query.end_date
    @monthly = Monthly.where(:start_date => @start_date, :provider_id=>current_provider_id).first
    @monthly = Monthly.new(:start_date=>@start_date, :provider_id=>current_provider_id) if @monthly.nil?
    @provider = current_provider

    if !can? :read, @monthly
      return redirect_to reports_path
    end

    #computes number of trips in and out of district by purpose
    counts_by_purpose = Trip.for_provider(current_provider_id).for_date_range(@start_date, @end_date)
        .includes(:customer).completed
    
    by_purpose = {}
    TRIP_PURPOSES.each do |purpose| 
      by_purpose[purpose] = {'purpose' => purpose, 'in_district' => 0, 'out_of_district' => 0}
    end
    @total = {'in_district' => 0, 'out_of_district' => 0}

    counts_by_purpose.each do |row|
      purpose = row.trip_purpose
      next unless by_purpose.member?(purpose)

      if row.in_district 
        by_purpose[purpose]['in_district'] += row.trip_count
        @total['in_district'] += row.trip_count
      else
        by_purpose[purpose]['out_of_district'] += row.trip_count
        @total['out_of_district'] += row.trip_count
      end
    end
        
    @trips_by_purpose = []
    TRIP_PURPOSES.each do |purpose| 
      @trips_by_purpose << by_purpose[purpose]
    end
    
    #compute monthly totals
    runs = Run.for_provider(current_provider_id).for_date_range(@start_date, @end_date)

    mileage_runs = runs.select("vehicle_id, min(start_odometer) as min_odometer, max(end_odometer) as max_odometer").group("vehicle_id").with_odometer_readings
    @total_miles_driven = 0
    mileage_runs.each {|run| @total_miles_driven += (run.max_odometer.to_i - run.min_odometer.to_i) }

    @turndowns = Trip.turned_down.for_date_range(@start_date, @end_date).for_provider(current_provider_id).count
    @volunteer_driver_hours = hms_to_hours(runs.for_volunteer_driver.sum("actual_end_time - actual_start_time") || "0:00:00")
    @paid_driver_hours = hms_to_hours(runs.for_paid_driver.sum("actual_end_time - actual_start_time")  || "0:00:00")

    trip_customers = Trip.select("DISTINCT customer_id").for_provider(current_provider_id).completed
    prior_customers_in_fiscal_year = trip_customers.for_date_range(fiscal_year_start_date(@start_date), @start_date).map {|x| x.customer_id}
    customers_this_period = trip_customers.for_date_range(@start_date, @end_date).map {|x| x.customer_id}
    @undup_riders = (customers_this_period - prior_customers_in_fiscal_year).size
  end

  def show_trips_for_verification
    query_params = params[:query] || {}
    @query = Query.new(query_params)
    @trip_results = TRIP_RESULT_CODES.map { |k,v| [v,k] }
    
    unless @trips.present?
      @trips = Trip.for_provider(current_provider_id).for_date_range(@query.start_date,@query.end_date) 
      @trips = @trips.for_cab     if @query.trip_display == "Cab Trips"
      @trips = @trips.not_for_cab if @query.trip_display == "Not Cab Trips"
    end
  end

  def update_trips_for_verification
    @trips = Trip.update(params[:trips].keys, params[:trips].values).reject {|t| t.errors.empty?}
    if @trips.empty?
      redirect_to({:action => :show_trips_for_verification}, :notice => "Trips updated successfully" )
    else
      @trip_results = TRIP_RESULT_CODES.map { |k,v| [v,k] }
      render :action => :show_trips_for_verification
    end
  end

  def show_runs_for_verification
    query_params = params[:query] || {}
    @query = Query.new(query_params)

    @drivers  = Driver.active.where(:provider_id=>current_provider_id).default_order
    @vehicles = Vehicle.active.where(:provider_id=>current_provider_id)
    @runs = Run.for_provider(current_provider_id).for_date_range(@query.start_date,@query.end_date) unless @runs.present?
  end

  def update_runs_for_verification
    @runs = Run.update(params[:runs].keys, params[:runs].values).reject {|t| t.errors.empty?}
    if @runs.empty?
      redirect_to({:action => :show_runs_for_verification}, :notice => "Runs updated successfully" )
    else
      @drivers  = Driver.active.where(:provider_id=>current_provider_id).default_order
      @vehicles = Vehicle.active.where(:provider_id=>current_provider_id)
      render :action => :show_runs_for_verification
    end
  end

  def donations
    query_params = params[:query] || {}
    @query = Query.new(query_params)

    @donations_by_customer = {}
    @total = 0
    for trip in Trip.for_provider(current_provider_id).for_date_range(@query.start_date, @query.end_date).where(["donation > 0"]).order(:pickup_time)
      customer = trip.customer
      if ! @donations_by_customer.member? customer
        @donations_by_customer[customer] = trip.donation
      else
        @donations_by_customer[customer] += trip.donation
      end
      @total += trip.donation
    end
    @customers = @donations_by_customer.keys.sort_by {|customer| [customer.last_name, customer.first_name] }
  end

  def cab
    query_params = params[:query] || {}
    @query = Query.new(query_params)

    @trips = Trip.for_provider(current_provider_id).for_date_range(@query.start_date, @query.end_date).for_cab.order(:pickup_time)
  end

  def age_and_ethnicity
    query_params = params[:query] || {}
    @query = Query.new(query_params)
    @start_date = @query.start_date
    @end_date = @query.end_date

    #we need new riders this month, where new means "first time this fy"
    #so, for each trip this month, find the customer, then find out whether 
    # there was a previous trip for this customer this fy

    trip_customers = Trip.select("DISTINCT customer_id").for_provider(current_provider_id).completed
    prior_customers_in_fiscal_year = trip_customers.for_date_range(fiscal_year_start_date(@start_date), @start_date).map {|x| x.customer_id}
    customers_this_period = trip_customers.for_date_range(@start_date, @end_date).map {|x| x.customer_id}
    
    new_customers = Customer.where(:id => (customers_this_period - prior_customers_in_fiscal_year))
    earlier_customers = Customer.where(:id => prior_customers_in_fiscal_year)

    @this_month_unknown_age = 0
    @this_month_sixty_plus = 0
    @this_month_less_than_sixty = 0

    @this_year_unknown_age = 0
    @this_year_sixty_plus = 0
    @this_year_less_than_sixty = 0

    @counts_by_ethnicity = {}
    @provider = current_provider

    #first, handle the customers from this month
    for customer in new_customers
      age = customer.age_in_years
      if age.nil?
        @this_month_unknown_age += 1
        @this_year_unknown_age += 1
      elsif age > 60
        @this_month_sixty_plus += 1
        @this_year_sixty_plus += 1
      else
        @this_month_less_than_sixty += 1
        @this_year_less_than_sixty += 1
      end
      
      ethnicity = customer.ethnicity || "Unspecified"
      if ! @counts_by_ethnicity.member? ethnicity
        @counts_by_ethnicity[ethnicity] = {'month' => 0, 'year' => 0}
      end
      @counts_by_ethnicity[ethnicity]['month'] += 1
      @counts_by_ethnicity[ethnicity]['year'] += 1
    end

    #now the customers who appear earlier in the year 
    for customer in earlier_customers
      age = customer.age_in_years
      if age.nil?
        @this_year_unknown_age += 1
      elsif age > 60
        @this_year_sixty_plus += 1
      else
        @this_year_less_than_sixty += 1
      end

      ethnicity = customer.ethnicity || "Unspecified"
      if ! @counts_by_ethnicity.member? ethnicity
        @counts_by_ethnicity[ethnicity] = {'month' => 0, 'year' => 0}
      end
      @counts_by_ethnicity[ethnicity]['year'] += 1
    end

  end

  def daily_manifest
    authorize! :read, Trip

    query_params = params[:query]
    @query = Query.new(query_params)
    @date = @query.start_date

    cab = Driver.new(:name=>'Cab') #dummy driver for cab trips

    trips = Trip.scheduled.for_provider(current_provider_id).for_date(@date).includes(:pickup_address,:dropoff_address,:customer,:mobility,{:run => :driver}).order(:pickup_time)
    if @query.driver_id == -2 # All
      # No additional filtering
    elsif @query.driver_id == -1 # Cab
      trips = trips.for_cab
    else
      authorize! :read, Driver.find(@query.driver_id)
      trips = trips.for_driver(@query.driver_id)
    end
    @trips = trips.group_by {|trip| trip.run ? trip.run.driver : cab }
  end

  def daily_manifest_with_cab
    prep_with_cab
    render "daily_manifest"
  end

  def daily_manifest_by_half_hour
    daily_manifest #same data, operated on differently in the view
    @start_hour = 7
    @end_hour = 17
  end

  def daily_manifest_by_half_hour_with_cab
    prep_with_cab
    @start_hour = 7
    @end_hour = 17
    render "daily_manifest_by_half_hour"
  end

  def daily_trips
    authorize! :read, Trip

    query_params = params[:query]
    @query = Query.new(query_params)
    @date = @query.start_date

    @trips = Trip.for_provider(current_provider_id).for_date(@date).includes(:pickup_address,:dropoff_address,:customer,:mobility,{:run => :driver}).order(:pickup_time)
  end

  private

  def prep_with_cab
    authorize! :read, Trip

    query_params = params[:query]
    @query = Query.new(query_params)
    @date = @query.start_date

    trips = Trip.scheduled.for_provider(current_provider_id).for_date(@date).includes(:pickup_address,:dropoff_address,:customer,:mobility,{:run => :driver}).order(:pickup_time)
    @cab_trips = Trip.for_cab.scheduled.for_provider(current_provider_id).for_date(@date).includes(:pickup_address,:dropoff_address,:customer,:mobility,{:run => :driver}).order(:pickup_time)

    if @query.driver_id == -2 # All
      trips = trips.not_for_cab
    else
      authorize! :read, Driver.find(@query.driver_id)
      trips = trips.for_driver(@query.driver_id)
    end
    @trips = trips.group_by {|trip| trip.run.try(:driver) }
  end

  def hms_to_hours(hms)
    #argument is a string of the form hours:minutes:seconds.  We would like
    #a float of hours
    if !hms or hms.empty?
      return 0
    end
    hours, minutes, seconds = hms.split(":").map &:to_i
    hours ||= 0
    minutes ||= 0
    seconds ||= 0
    return hours + minutes / 60.0 + seconds / 3600.0
  end

  def fiscal_year_start_date(date)
    year = (date.month < 7 ? date.year - 1 : date.year)
    Date.new(year, 7, 1)
  end
end
