class DriversController < ApplicationController
  load_and_authorize_resource

  def new
  end

  def index
    redirect_to provider_path(current_provider)
  end

  def edit
  end

  def update
    @driver.update_attributes(params[:driver])
    if @driver.save
      flash[:notice] = "Driver updated"
      redirect_to provider_path(current_user.current_provider)
    else
      render :action=>:edit
    end
  end

  def create
    @driver.provider = current_provider
    if @driver.save
      flash[:notice] = "Driver created"
      redirect_to provider_path(current_provider)
    else
      render :action=>:new
    end
  end

  def destroy
    @driver.destroy
    redirect_to provider_path(current_provider)
  end

end
