class TripsController < ApplicationController
  load_and_authorize_resource

  def new
    @trip = Trip.new
  end

  def create
    trip_params = params[:trip]
    trip_params[:status] = "pending"
    
    customer = Customer.find(trip_params[:customer_id])
    authorize! :read, customer

    @trip = Trip.new(trip_params)

  end

  def index

  end

end
