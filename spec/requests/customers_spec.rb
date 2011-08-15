require 'spec_helper'

describe "Customers" do
  context "for admin" do
    attr_reader :user

    before :each do
      @user = create_role(:level => 100).user
      visit new_user_session_path
      fill_in 'user_email', :with => user.email
      fill_in 'Password', :with => 'password'
      click_button 'Sign in'
    end
    
    describe "GET /customer/:id" do
      attr_reader :customer
      
      context "when the customer has associated trips" do
        attr_reader :trips
        
        before do
          @customer = create_customer :provider => user.current_provider
          @trips    = (1..5).map { create_trip :customer => customer }
          visit customer_path(@customer)
        end
        
        it "shows duplicate link" do
          page.has_link?("Duplicate").should be
        end
        
        it "renders the duplicate customer dialog" do
          page.has_selector?("#confirm-destroy").should be
        end
      end
      
      context "when the customer has no associated trips" do
        before do
          @customer = create_customer :provider => user.current_provider
        end
        
        it "shows delete link" do
          visit customer_path(@customer)
          page.has_link?("Delete").should be
        end
      end
    end
    
    describe "DELETE /customer/:id" do
      attr_reader :customer
      
      before do
        @customer = create_customer :provider => user.current_provider
      end
      
      context "when the customer has trips" do
        attr_reader :trips
        
        before do
          @trips = (1..5).map { create_trip :customer => customer }
        end
        
        context "when customer_id is present" do
          attr_reader :other
          
          before do
            @other = create_customer :provider => user.current_provider
          end
          
          it "redirects to other customer" do
            pending "redirecting to sign in for some reason" 
            
            delete customer_path(@customer, :customer_id => other.id)
            response.should redirect_to(customer_path(other))
          end
        end
        
        context "when customer_id is not present" do
          it "renders show with an error" do
            pending "redirecting to sign in for some reason" 
            
            delete customer_path(@customer)
            page.has_content?("could not be deleted").should be
          end
        end
      end
      
      context "when the customer does not have trips" do
        it "redirects to customer index" do
          pending "redirecting to sign in for some reason" 
          
          delete customer_path(@customer)
          response.should redirect_to(customers_path)
        end
      end
    end
  end
  
  context "for editor" do
    attr_reader :user

    before do
      @user = create_role(:level => 50).user
      visit new_user_session_path
      fill_in 'user_email', :with => user.email
      fill_in 'Password', :with => 'password'
      click_button 'Sign in'
    end
    
    describe "GET /customer/:id" do
      attr_reader :customer
      
      context "when the customer has associated trips" do
        attr_reader :trips
        
        before do
          @customer = create_customer :provider => user.current_provider
          @trips    = (1..5).map { create_trip :customer => customer }
        end
        
        it "does not show delete link" do
          visit customer_path(@customer)
          page.has_link?("Delete").should_not be
        end
      end
      
      context "when the customer has no associated trips" do
        before do
          @customer = create_customer :provider => user.current_provider
        end
        
        it "shows the delete link" do
          visit customer_path(@customer)
          page.has_link?("Delete").should be
        end
      end
    end
    
    describe "DELETE /customer/:id" do
      attr_reader :customer
      
      before do
        @customer = create_customer :provider => user.current_provider
      end
      
      it "redirects to customer index" do
        pending "redirecting to sign in for some reason" 
        
        delete customer_path(@customer)
        response.should redirect_to(customers_path)
      end
    end
  end
end
