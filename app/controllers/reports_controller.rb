def bind(args)
  return ActiveRecord::Base.__send__(:sanitize_sql_for_conditions, args, '')
end

class ReportsController < ApplicationController

  def index
  end

  def vehicles
    @vehicles = Vehicle.accessible_by(current_ability)
  end

  def vehicle
    report_params = params[:report]
    @vehicle = Vehicle.accessible_by(current_ability).find report_params[:vehicle_id]
    @start_date = Date.new(report_params['for_month(1i)'].to_i, 
                           report_params['for_month(2i)'].to_i)
    @end_date = @start_date.next_month

    @events = @vehicle.vehicle_maintenance_events.where(["service_date BETWEEN ? and ?", @start_date, @end_date])

    month_runs = Run.where(["vehicle_id = ? and date BETWEEN ? and ? ", @vehicle.id, @start_date, @end_date])

    @total_hours = month_runs.sum("start_time - end_time").to_i 
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
    provider_id = current_user.current_provider_id
    if params[:id]
      @monthly = Monthly.find(params[:id])      
      @start_date = @monthly.start_date
      @end_date = @monthly.end_date
    else
      if params[:report]
        report_params = params[:report]
        @start_date = Date.new(report_params['for_month(1i)'].to_i, 
                               report_params['for_month(2i)'].to_i)
      else
        now = Date.today
        @start_date = Date.new(now.year, now.month, 1).prev_month
      end
      @end_date = @start_date.next_month
      @monthly = Monthly.where(["start_date = ? and end_date = ?", @start_date, @end_date]).first
    end

    if !can? :read, @monthly
      return redirect_to "/"
    end

    #computes number of trips in and out of district by purpose

    sql = "select trip_purpose, in_district, count(*) as ct from trips where provider_id = ? and pickup_time between ? and ? group by trip_purpose, in_district"

    counts_by_purpose = ActiveRecord::Base.connection.select_all(bind(
        [sql, provider_id, @start_date, @end_date]))

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
    month_runs = Run.where(["provider_id = ? and date BETWEEN ? and ? ", provider_id, @start_date, @end_date])

    first_run = month_runs.order("date").first
    if first_run
      start_odometer = first_run.start_odometer
      end_odometer = month_runs.order("date").last.start_odometer
      @total_miles_driven = end_odometer - start_odometer 
    end

    @turndowns = Trip.where(["provider_id =? and trip_result = 'TURNDOWN' and pickup_time BETWEEN ? and ? ", provider_id, @start_date, @end_date]).count

    #FIXME: this is not actually goint to work, because you can't 
    #just subtract times in sql and expect to get something useful
    
    @volunteer_driver_hours = month_runs.where("paid = true").sum("end_time - start_time") || 0
    @paid_driver_hours = month_runs.where("paid = false").sum("end_time - start_time")  || 0

    if @monthly.nil?
      @monthly = Monthly.create(:start_date=>@start_date, :end_date=>@end_date)
    end
  end

  def update_monthly
    @monthly = Monthly.find(params[:monthly][:id])

    if can? :edit, @monthly
      @monthly.update_attributes(params[:monthly])
    end
    redirect_to :action=>:service_summary, :id => @monthly.id

  end

end
