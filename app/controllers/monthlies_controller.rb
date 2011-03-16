class MonthliesController < ApplicationController
  load_and_authorize_resource

  def new
  end

  def index
    redirect_to provider_path(current_user.current_provider)
  end

  def edit
  end

  def update
    @monthly.update_attributes(params[:monthly])
    @monthly.save!
    flash[:notice] = "Monthly report updated"
    redirect_to provider_path(current_user.current_provider)
  end

  def create
    @monthly.provider = current_user.current_provider
    @monthly.save!
    flash[:notice] = "Monthly report created"
    redirect_to provider_path(current_user.current_provider)
  end

end
