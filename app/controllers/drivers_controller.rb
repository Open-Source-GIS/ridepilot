class DriversController < ApplicationController
  load_and_authorize_resource

  def new
    prep_edit
  end

  def index
    redirect_to provider_path(current_provider)
  end

  def edit
    prep_edit
  end

  def update
    @driver.update_attributes(params[:driver])
    if @driver.save
      flash[:notice] = "Driver updated"
      redirect_to provider_path(current_user.current_provider)
    else
      prep_edit
      render :action=>:edit
    end
  end

  def create
    @driver.provider = current_provider
    if @driver.save
      flash[:notice] = "Driver created"
      redirect_to provider_path(current_provider)
    else
      prep_edit
      render :action=>:new
    end
  end

  def destroy
    @driver.destroy
    redirect_to provider_path(current_provider)
  end

  private
  
  def prep_edit
    @available_users = @driver.provider.users - User.drivers(@driver.provider)
    @available_users << @driver.user if @driver.user
  end
end
