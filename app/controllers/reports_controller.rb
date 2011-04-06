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


end
