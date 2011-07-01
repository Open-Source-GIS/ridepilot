require 'spec_helper'

describe "Users" do
  describe "GET /users/sign_in" do
    attr_reader :user
    
    before do
      @user = create_role.user
      
    end
    
    it "works" do
      get new_user_session_path
      response.should be_success
    end

    it "signs me in" do
      visit new_user_session_path
      fill_in 'user_email', :with => user.email
      fill_in 'Password', :with => 'password'
      click_button 'Sign in'
    end
  end
end
