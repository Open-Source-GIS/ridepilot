# a note on general run workflow:
# Runs are created as part of the trip scheduling 
# process; they're associated with a vehicle and
# a driver.  At the end of the day, the driver
# must update the run with post-run data like
# odometer start/end and no-shows.  That is 
# presented by my_runs and end_of_day

class RunsController < ApplicationController
  load_and_authorize_resource

  def index
    if params[:date] and params[:date].size > 0
      params[:date] = Date.parse(params[:date])
    else
      params[:date] = Date.today
    end
    @runs = @runs.where(["cast(scheduled_start_time as date) = ?", params[:date]])
    @date = params[:date]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
  end

  def new
    @run = Run.new
    @run.provider_id = current_user.current_provider_id
    @drivers = Driver.where(:provider_id=>@run.provider_id)
    @vehicles = Vehicle.where(:provider_id=>@run.provider_id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  def uncompleted_runs
    @runs = Run.where("complete = false").order("date desc")
    render "index"
  end

  def edit
    @drivers = Driver.where(:provider_id=>@run.provider_id)
    @vehicles = Vehicle.where(:provider_id=>@run.provider_id)
  end

  def create
    run_params = params[:run]
    provider = current_user.current_provider
    authorize! :manage, provider
    run_params[:provider_id] = provider_id

    @run = Run.new(run_params)

    respond_to do |format|
      if @run.save
        format.html { redirect_to(@run, :notice => 'Run was successfully created.') }
        format.xml  { render :xml => @run, :status => :created, :location => @run }
      else
        @drivers = Driver.where(:provider_id=>@run.provider_id)
        @vehicles = Vehicle.where(:provider_id=>@run.provider_id)

        format.html { render :action => "new" }
        format.xml  { render :xml => @run.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    run_params = params[:run]
    provider = current_user.current_provider
    authorize! :manage, provider
    run_params[:provider_id] = provider.id

    respond_to do |format|
      if @run.update_attributes(run_params)
        format.html { redirect_to(@run, :notice => 'Run was successfully updated.') }
        format.xml  { head :ok }
      else
        @drivers = Driver.where(:provider_id=>@run.provider_id)
        @vehicles = Vehicle.where(:provider_id=>@run.provider_id)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @run.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @run = Run.find(params[:id])
    @run.destroy

    respond_to do |format|
      format.html { redirect_to(runs_url) }
      format.xml  { head :ok }
    end
  end
end
