require 'spec_helper'

describe Customer do
  describe "replace_with!" do
    context "when no customer id" do
      attr_reader :customer
      
      before do
        @customer = create_customer
      end
      
      it "is false" do
        @customer.replace_with!("").should_not be
      end
    end
    
    context "when invalid customer id" do
      attr_reader :customer
      
      before do
        @customer = create_customer
      end
      
      it "is false" do
        @customer.replace_with!(-1).should_not be
      end
    end
    
    context "when valid customer id" do
      context "when customer has trips" do
        attr_reader :customer, :trips, :other

        before do
          @customer = create_customer
          @trips    = (1..5).map { create_trip :customer => customer }
          @other    = create_customer
          
          customer.replace_with!(other.id)
        end
        
        it "destroys self" do
          Customer.exists?(customer.id).should_not be
        end

        it "moves self's trips to other customer" do
          for trip in trips
            trip.reload.customer.should == other
          end
        end
      end
      
      context "when customer has no trips" do
        attr_reader :customer

        before do
          @customer = create_customer
        end
        
        it "destroys self" do

        end
      end
    end
  end
end
