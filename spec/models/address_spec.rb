require 'spec_helper'

describe Address do
  describe "replace_with!" do
    context "when no address id" do
      attr_reader :address
      
      before do
        @address = create_address
      end
      
      it "is false" do
        @address.replace_with!("").should_not be
      end
    end
    
    context "when invalid address id" do
      attr_reader :address
      
      before do
        @address = create_address
      end
      
      it "is false" do
        @address.replace_with!(-1).should_not be
      end
    end
    
    context "when valid address id" do
      context "when address has trips_from" do
        attr_reader :address, :trips, :other

        before do
          @address = create_address
          @trips    = (1..5).map { create_trip :pickup_address => address }
          @other    = create_address
          
          address.replace_with!(other.id)
        end
        
        it "destroys self" do
          Address.exists?(address.id).should_not be
        end

        it "moves self's trips to other address" do
          for trip in trips
            trip.reload.pickup_address.should == other
          end
        end
      end
      
    end
    
    context "when valid address id" do
      context "when address has trips_to" do
        attr_reader :address, :trips, :other

        before do
          @address = create_address
          @trips    = (1..5).map { create_trip :dropoff_address => address }
          @other    = create_address
          
          address.replace_with!(other.id)
        end
        
        it "destroys self" do
          Address.exists?(address.id).should_not be
        end

        it "moves self's trips to other address" do
          for trip in trips
            trip.reload.dropoff_address.should == other
          end
        end
      end
      
    end
    
  end
end
