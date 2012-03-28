class MonthliesController < ApplicationController
  load_and_authorize_resource

  def new

  end

  def index
    @monthlies = @monthlies.order(:start_date)
  end

  def edit

  end

  def update
    @monthly.update_attributes(params[:monthly])
    if @monthly.save
      flash[:notice] = "Monthly report updated"
      redirect_to monthlies_path
    else
      render :edit
    end
  end

  def create
    @monthly.provider = current_provider
    if @monthly.save
      flash[:notice] = "Monthly report created"
      redirect_to monthlies_path
    else
      render :new
    end
  end

end
