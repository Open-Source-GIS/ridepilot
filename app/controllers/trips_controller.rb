class TripsController < ApplicationController
  load_and_authorize_resource

  def new
    @trip = Trip.new
  end

  def create
    trip_params = params[:trip]
    trip_params[:status] = "pending"
    
    client = Client.find(trip_params[:client_id])
    authorize! :read, client

    @trip = Trip.new(trip_params)

  end

  def index

  end

end
