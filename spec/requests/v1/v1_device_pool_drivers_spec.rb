require 'spec_helper'

describe "V1::device_pool_drivers" do
  
  describe "POST /v1/device_pool_drivers/:id.json" do
    context "when valid status update" do
      attr_reader :device_pool_driver
      
      before do
        @device_pool_driver = create_device_pool_driver :driver => create_driver, :device_pool => create_device_pool
        
        post "/v1/device_pool_drivers/#{device_pool_driver.id}.json", :device_pool_driver => { :status => DevicePoolDriver::Statuses.first }
      end
      
      it "returns 200" do
        response.status.should be(200)
      end
      
      it "returns device as json" do
        response.body.should == {:device_pool_driver => device_pool_driver.reload.as_json }.to_json
      end
    end
    
    context "when invalid status update" do
      attr_reader :device_pool_driver
      
      before do
        @device_pool_driver = create_device_pool_driver :driver => create_driver, :device_pool => create_device_pool
        
        post "/v1/device_pool_drivers/#{device_pool_driver.id}.json", :device_pool_driver => { :status => "XXX" }
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
      
      before do        
        post "/v1/device_pool_drivers/0.json", :device_pool_driver => { :status => DevicePoolDriver::Statuses.first }
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
