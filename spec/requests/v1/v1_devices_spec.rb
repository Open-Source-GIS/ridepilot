require 'spec_helper'

describe "V1::Devices" do
  describe "POST /v1/devices" do
    context "when valid params" do
      it "returns status 201" do
        post "/v1/devices", :android_id => "1234567890abcdef"
        response.status.should be(201)
      end
    end

    context "when invalid params" do
      it "returns status 400" do
        post "/v1/devices"
        response.status.should be(400)
      end
    end
  end
  
  describe "PUT /v1/devices/:android_id" do
    context "when valid params" do
      attr_reader :driver, :device
      
      before do
        @device = create_device
        @driver = create_driver
        
        post "/v1/devices/#{device.android_id}", "_method" => "PUT", :device => { :driver_id => driver.id }
      end
      
      it "returns 200" do
        response.status.should be(200)
      end
      
      it "returns device as json" do
        response.body.should == {:device => device.as_json }.to_json
      end
    end
  end
end
