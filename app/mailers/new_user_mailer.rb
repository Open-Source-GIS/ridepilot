class NewUserMailer < ActionMailer::Base
  default :from => EMAIL_FROM


  def new_user_email(user, password)
    @user     = user
    @password = password
    @url      = edit_user_password_url :reset_password_token => user.reset_password_token, :initial => true
    mail(:to => user.email,  :subject => "Welcome to RidePilot")
 end


end
