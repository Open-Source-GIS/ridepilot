class ProvidersController < ApplicationController
  load_and_authorize_resource

  def index
  end
  
  def show
  end

  def delete_role
    role = Role.find(params[:role_id])
    authorize! :edit, role
    role.destroy
    redirect_to provider_path(params[:provider_id])
  end


  def change_role
    role = Role.find(params[:role][:id])
    authorize! :edit, role
    role.admin = params[:role][:admin]
    role.save!
    redirect_to provider_path(params[:provider_id])
  end

end
