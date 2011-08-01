require 'spec_helper'

describe "V1::device_pool_drivers" do
  
  describe "POST /device_pool_drivers.json" do
    context "when not using https" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool        
      end
      
      it "raises routing error" do
        lambda {
          post v1_device_pool_drivers_path(:user => { :email => user.email, :password => "password" }, :secure => false, :format => "json")        
        }.should raise_error(ActionController::RoutingError)        
      end
    end
    
    context "when not passing user params" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool
          
        post v1_device_pool_drivers_path(:secure => true, :format => "json")
      end

      it "returns 401" do
        response.status.should be(401)
      end

      it "returns error" do
        response.body.should match("No user found")
      end
    end
    
    context "when passing bad user params" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool
          
        post v1_device_pool_drivers_path(:user => { :email => user.email, :password => "wrong" }, :secure => true, :format => "json")
      end

      it "returns 401" do
        response.status.should be(401)
      end

      it "returns error" do
        response.body.should match("No user found")
      end
    end
    
    context "when user has no device_pool_driver" do
      attr_reader :device_pool_driver, :user, :current_user

      before do
        @current_user       = create_user :password => "password", :password_confirmation => "password"
        @user               = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => current_user
        create_role :level => 0, :user => user
        
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool

        post v1_device_pool_drivers_path(:user => { :email => current_user.email, :password => "password" }, :secure => true, :format => "json")
      end

      it "returns 401" do
        response.status.should be(401)
      end

      it "returns error" do
        response.body.should match("User does not have access to this resource")
      end
    end
    
    context "when user has device_pool_driver" do
      attr_reader :device_pool_driver, :user

      before do
        @user               = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool

        post v1_device_pool_drivers_path(:user => { :email => user.email, :password => "password" }, :secure => true, :format => "json")
      end

      it "returns 200" do
        response.status.should be(200)
      end

      it "returns resource_url" do
        response.body.should match( v1_device_pool_driver_url(:id => device_pool_driver.id, :secure => true, :format => "json") )
      end
    end
  end
  
  describe "POST /v1/device_pool_drivers/:id.json" do
    context "when not using https" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool        
      end
      
      it "raises routing error" do
        lambda {
          post v1_device_pool_driver_path(:id => device_pool_driver.id, :user => { :email => user.email, :password => "password" }, :device_pool_driver => { :status => "XXX" }, :secure => false, :format => "json")        
        }.should raise_error(ActionController::RoutingError)        
      end
    end
    
    context "when not passing user params" do
      attr_reader :device_pool_driver
      
      before do
        @device_pool_driver = create_device_pool_driver :driver => create_driver, :device_pool => create_device_pool
        
        post v1_device_pool_driver_path(:id => device_pool_driver.id, :secure => true, :format => "json")
      end
      
      it "returns 401" do
        response.status.should be(401)
      end
      
      it "returns error" do
        response.body.should match("No user found")
      end
    end
    
    context "when passing bad user params" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user               = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool
                
        post v1_device_pool_driver_path(:id => device_pool_driver.id, :user => { :email => user.email, :password => "wrong" }, :secure => true, :format => "json")
      end
      
      it "returns 401" do
        response.status.should be(401)
      end
      
      it "returns error" do
        response.body.should match("No user found")
      end
    end
    
    context "when passing params that do not map to the driver for this resource" do
      attr_reader :device_pool_driver, :user, :current_user

      before do
        @current_user       = create_user :password => "password", :password_confirmation => "password"
        @user               = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => current_user
        create_role :level => 0, :user => user
        
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool

        post v1_device_pool_driver_path(:id => device_pool_driver.id, :user => { :email => current_user.email, :password => "password" }, :secure => true, :format => "json")
      end

      it "returns 401" do
        response.status.should be(401)
      end

      it "returns error" do
        response.body.should match("User does not have access to this resource")
      end
    end
    
    context "when valid status update" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool
        
        post v1_device_pool_driver_path(:id => device_pool_driver.id, :user => { :email => user.email, :password => "password" }, :secure => true, :format => "json")
      end
      
      it "returns 200" do
        response.status.should be(200)
      end
      
      it "returns device as json" do
        response.body.should == {:device_pool_driver => device_pool_driver.reload.as_mobile_json }.to_json
      end
    end
    
    context "when invalid status update" do
      attr_reader :device_pool_driver, :user
      
      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool
                
        post v1_device_pool_driver_path(:id => device_pool_driver.id, :user => { :email => user.email, :password => "password" }, :device_pool_driver => { :status => "XXX" }, :secure => true, :format => "json")        
      end
      
      it "returns 400" do
        response.status.should be(400)
      end
      
      it "returns error as json" do
        json = JSON.parse(response.body)
        json.should include("error")
      end
    end
    
    context "when invalid device_pool_driver_id" do
      attr_reader :device_pool_driver, :user

      before do
        @user = create_user :password => "password", :password_confirmation => "password"
        create_role :level => 0, :user => user
        @device_pool_driver = create_device_pool_driver :driver => create_driver(:user => @user), :device_pool => create_device_pool
        
        post v1_device_pool_driver_path(:id => 0, :user => { :email => user.email, :password => "password" }, :device_pool_driver => { :status => DevicePoolDriver::Statuses.first }, :secure => true, :format => "json")        
      end
      
      it "returns 404" do
        response.status.should be(404)
      end
      
      it "returns error as json" do
        json = JSON.parse(response.body)
        json.should include("error")
      end
    end
  end
end
