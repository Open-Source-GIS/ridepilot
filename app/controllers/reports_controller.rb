class Query
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_accessor :start_date
  attr_accessor :end_date
  attr_accessor :vehicle_id
  attr_accessor :driver_id

  def convert_date(obj, base)
    return Date.new(obj["#{base}(1i)"].to_i,obj["#{base}(2i)"].to_i,(obj["#{base}(3i)"] || 1).to_i)
  end

  def initialize(params = nil)
    now = Date.today
    @start_date = Date.new(now.year, now.month, 1).prev_month
    @end_date = start_date.next_month
    if params
      if params["start_date(1i)"]
        @start_date = convert_date(params, :start_date)
      end
      if params["end_date(1i)"]
        @end_date = convert_date(params, :end_date)
      end
      if params["vehicle_id"]
        @vehicle_id = params["vehicle_id"]
      end
      if params["driver_id"]
        @driver_id = params["driver_id"]
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
    @driver_query = Query.new
    cab = Driver.new(:id=>"cab", :first_name=>"Cab")
    all = Driver.new(:id=>"all", :first_name=>"All")
    @drivers =  [all, cab] + Driver.accessible_by(current_ability)
  end

  def vehicles
    @vehicles = Vehicle.accessible_by(current_ability)
    @query = Query.new
  end

  def vehicle
    query_params = params[:query]
    @query = Query.new(query_params)
    @vehicles = Vehicle.accessible_by(current_ability)

    @vehicle = Vehicle.accessible_by(current_ability).find @query.vehicle_id
    @start_date = @query.start_date
    @end_date = @start_date.next_month

    @covered_events = @vehicle.vehicle_maintenance_events.where(["service_date BETWEEN ? and ? and reimbursable=true", @start_date, @end_date])

    @noncovered_events = @vehicle.vehicle_maintenance_events.where(["service_date BETWEEN ? and ? and reimbursable=false", @start_date, @end_date])

    month_runs = Run.where(["vehicle_id = ? and date BETWEEN ? and ? and complete=true", @vehicle.id, @start_date, @end_date])

    @total_hours = month_runs.sum("actual_start_time - actual_end_time").to_i 
    @total_rides = Trip.find(:all, :joins => :run, :conditions=>{:runs => {:vehicle_id=>@vehicle.id }}).count.to_i #fixme: does not consider guests and attendants -- should it?


    first_run = month_runs.order("date").first
    if first_run
      @beginning_odometer = first_run.start_odometer
      @ending_odometer = month_runs.order("date").last.start_odometer
    else
      #no runs this month
      @beginning_odometer = -1
      @ending_odometer = -1
    end

  end

  def service_summary
    if params[:query]
      query_params = params[:query]
      @query = Query.new(query_params)
      @start_date = @query.start_date
      @monthly = Monthly.where(["start_date = ? and end_date = ?", @start_date, @start_date.next_month]).first
    elsif params[:id]
      @monthly = Monthly.find(params[:id])      
      @start_date = @monthly.start_date
      @end_date = @monthly.end_date
    else
      now = Date.today
      @start_date = Date.new(now.year, now.month, 1).prev_month
    end

    @query = Query.new
    @query.start_date = @start_date
    @end_date = @start_date.next_month
    if @monthly.nil?
      @monthly = Monthly.create(:start_date=>@start_date, :end_date=>@end_date, :provider_id=>current_provider_id)
    end

    if !can? :read, @monthly
      return redirect_to "/"
    end

    #computes number of trips in and out of district by purpose

    sql = "select trip_purpose, in_district, count(*) as ct from trips where provider_id = ? and pickup_time between ? and ? group by trip_purpose, in_district"

    counts_by_purpose = ActiveRecord::Base.connection.select_all(bind(
        [sql, current_provider_id, @start_date, @end_date]))

    by_purpose = {}
    for purpose in TRIP_PURPOSES
      by_purpose[purpose] = {'purpose' => purpose, 'in_district' => 0, 'out_of_district' => 0}
    end
    @total = {'in_district' => 0, 'out_of_district' => 0}

    for row in counts_by_purpose
      purpose = row[0]
      if !by_purpose.member? purpose
        next
      end
      if row[1]
        by_purpose[purpose]['in_district'] = row[2]
        @total['in_district'] += row[2]
      else
        by_purpose[purpose]['out_of_district'] = row[2]
        @total['out_of_district'] += row[2]
      end
    end
    @trips_by_purpose = []
    for purpose in TRIP_PURPOSES
      @trips_by_purpose << by_purpose[purpose]
    end
purpose
    #compute monthly totals
    month_runs = Run.where(["provider_id = ? and date BETWEEN ? and ? and start_odometer is not null and end_odometer is not null", current_provider_id, @start_date, @end_date])

    first_run = month_runs.order("date").first
    if first_run
      start_odometer = first_run.start_odometer
      end_odometer = month_runs.order("date").last.start_odometer
      @total_miles_driven = end_odometer - start_odometer 
    end

    @turndowns = Trip.where(["provider_id =? and trip_result = 'TD' and pickup_time BETWEEN ? and ? ", current_provider_id, @start_date, @end_date]).count
    
    @volunteer_driver_hours = hms_to_hours(month_runs.where("paid = true").sum("actual_end_time - actual_start_time") || "0:00:00")
    @paid_driver_hours = hms_to_hours(month_runs.where("paid = false").sum("actual_end_time - actual_start_time")  || "0:00:00")


    undup_riders_sql = "select count(*) as undup_riders from (select customer_id, fiscal_year(pickup_time) as year, min(fiscal_month(pickup_time)) as month from trips where provider_id=? and trip_result = 'COMP' group by customer_id, year) as  morx where date (year || '-' || month || '-' || 1)  between ? and ? "

    year_start_date = Date.new(@start_date.year, 1, 1)
    year_end_date = year_start_date.next_year

    row = ActiveRecord::Base.connection.select_one(bind([undup_riders_sql, current_provider_id, year_start_date, year_end_date]))

    @undup_riders = row['undup_riders'].to_i

  end

  def update_monthly
    @monthly = Monthly.find(params[:monthly][:id])
    params[:monthly][:provider_id] = current_provider_id
    if can? :edit, @monthly
      @monthly.update_attributes(params[:monthly])
    end
    redirect_to :action=>:service_summary, :id => @monthly.id

  end

  def donations
    query_params = params[:query]
    @query = Query.new(query_params)

    @donations_by_customer = {}
    @total = 0
    for trip in Trip.where(["provider_id = ? and pickup_time between ? and ? and donation > 0", current_provider_id, @query.start_date, @query.end_date])
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
    query_params = params[:query]
    @query = Query.new(query_params)

    @trips = Trip.where(["provider_id = ? and pickup_time between ? and ? and cab = true", current_provider_id, @query.start_date, @query.end_date])
  end

  def age_and_ethnicity
    query_params = params[:query]
    @query = Query.new(query_params)

    #we need new riders this month, where new means "first time this fy"

    #so, for each trip this month, find the customer, then find out whether 
    # there was a previous trip for this customer this fy


    sql = "select distinct customer_id from trips where provider_id = ? and pickup_time between ? and ?"

    customer_rows = ActiveRecord::Base.connection.select_all(bind(
        [sql, current_provider_id, @query.start_date, @query.end_date]))

    customer_ids = customer_rows.map {|x| x[0]}
    customers = Customer.where(:id => customer_ids)

    fy = @query.start_date.year
    if @query.start_date.month <= 6
      fy -= 1
    end
    fy_start_date = Date.new(fy, 7, 1)

    sql = "select distinct customer_id from trips where provider_id = ? and pickup_time between ? and ?"
    earlier_customer_rows = ActiveRecord::Base.connection.select_all(bind(
        [sql, current_provider_id, fy_start_date, @query.start_date]))

    earlier_customer_ids = earlier_customer_rows.map {|x| x[0]}
    earlier_customers = Customer.where(:id => earlier_customer_ids)
    earlier_customer_ids = Set.new(earlier_customer_ids)

    @this_month_unknown_age = 0
    @this_month_sixty_plus = 0
    @this_month_less_than_sixty = 0

    @this_year_unknown_age = 0
    @this_year_sixty_plus = 0
    @this_year_less_than_sixty = 0

    @counts_by_ethnicity = {}

    #first, handle the customers from this month
    for customer in customers
      if earlier_customer_ids.member? customer.id
        #not this customer's first visit
        next
      end
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

      if counts_by_ethnicity.member? customer.ethnicity.nil?
        @counts_by_ethnicity[customer.ethnicity] = {'month' => 0, 'year' => 0}
      end
      @counts_by_ethnicity[customer.ethnicity]['month'] += 1
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

      if counts_by_ethnicity.member? customer.ethnicity.nil?
        @counts_by_ethnicity[customer.ethnicity] = {'month' => 0, 'year' => 0}
      end
      @counts_by_ethnicity[customer.ethnicity]['year'] += 1
    end

  end

  def daily_manifest
    authorize! :read, Trip

    query_params = params[:query]
    @query = Query.new(query_params)
    @date = @query.start_date

    cab = Driver.new(name='cab') #dummy driver for cab trips

    if @query.driver_id == 'cab'

      @trips = {cab =>
        Trip.where(["(trip_result = '' or trip_result = 'COMP') and cab = true and provider_id=? and cast(pickup_time as date) = ? ", @query.driver_id, current_provider_id, @date])}

    elsif @query.driver_id == ''

      @trips = Trip.where(["(trip_result = '' or trip_result = 'COMP') and provider_id=? and cast(pickup_time as date) = ? ", current_provider_id, @date]).group_by {|trip| trip.run ? trip.run.driver : cab }

    else

      driver = Driver.find(@query.driver_id)
      authorize! :read, driver
      @trips = {driver =>
        Trip.find(:all, :joins=>:run, :conditions=> ["(trip_result = '' or trip_result = 'COMP') and cab = false and driver_id = ? and trips.provider_id=? and cast(pickup_time as date) = ? ", @query.driver_id, current_provider_id, @date])}
    end
  end

  def daily_manifest_by_half_hour
    daily_manifest #same data, operated on differently in the view
    @start_hour = 7
    @end_hour = 17
  end

  private

  def hms_to_hours(hms)
    #argumen is  a string of the form hours:minutes:seconds.  We would like
    #a float of hours

    hours, minutes, seconds = hms.split(":").map &:to_i
    return hours + minutes / 60.0 + seconds / 3600.0
  end

end
