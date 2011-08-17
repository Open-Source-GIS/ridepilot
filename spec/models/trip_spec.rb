require 'spec_helper'

describe Trip do
  describe "before validation" do
    context "when there are no runs yet" do
      before do
        Run.count.should == 0
      end
      
      it "creates an associated run" do
        lambda {
          trip = create_trip
          trip.run.should == Run.first
        }.should change(Run, :count).by(1)
      end
    end
  end
end
