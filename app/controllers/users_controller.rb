class UsersController < Devise::SessionsController

  def new
    if User.count == 0
      return redirect_to :init
    end
  end


  def show_init
    #create initial user
    if User.count > 0
      return redirect_to :action=>:new
    end
    @user = User.new
  end


  def init
    if User.count > 0
      return redirect_to :action=>:new
    end
    @user = User.new params[:user]
    @user.save!
    @role = Role.new ({:user_id=>@user.id, :provider_id=>1, :admin=>true})
    @role.save

    flash[:notice] = "OK, now sign in"
    redirect_to :action=>:new
  end

end
