class UsersController < Devise::SessionsController
  require 'new_user_mailer'
  
  def new
    #hooked up to sign_in
    if User.count == 0
      return redirect_to :action=>:show_init
    end
  end

  def new_user
    if User.count == 0
      return redirect_to :init
    end
    authorize! :edit, current_user.current_provider
    @user = User.new
  end

  def create_user
    authorize! :edit, current_user.current_provider

    #this user might already be a member of the site, but not of this
    #provider, in which case we ought to just set up the role
    user = User.where(:email=>params[:user][:email]).first
    if not user
      user = User.new(params[:user])
      user.password = user.password_confirmation = Devise.friendly_token[0..8]
      user.current_provider_id = current_user.current_provider_id
      user.save!
      NewUserMailer.new_user_email(user, user.password).deliver
    end

    Role.new(:user_id=>user.id, 
             :provider_id=>current_user.current_provider_id, 
             :level=>params[:role][:level]).save!

    flash[:notice] = "%s has been added and a password has been emailed" % user.email
    redirect_to provider_path(current_user.current_provider)
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
    @user.current_provider_id = 1
    @user.save!
    @role = Role.new ({:user_id=>@user.id, :provider_id=>1, :admin=>true})
    @role.save

    flash[:notice] = "OK, now sign in"
    redirect_to :action=>:new
  end

  def change_provider
    provider = Provider.find(params[:provider_id])
    if can? :view, provider
      current_user.current_provider_id = provider.id
      current_user.save!
    end
    redirect_to params[:come_from]
  end

end
