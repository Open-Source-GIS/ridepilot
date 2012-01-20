require 'spec_helper'

describe Trip do
  describe "before validation" do
    context "when there are no runs yet" do
      before do
        Run.count.should == 0
      end
      
      it "does not create an associated run" do
        lambda {
          trip = create_trip
          trip.run.should be_nil
        }.should_not change(Run, :count).by(1)
      end
    end
  end
  describe "after validation" do
    context "when creating a trip with repeating trip data" do
      attr_accessor :trip
      before do
        @trip = new_trip(
          :repeats_mondays => true, 
          :repeats_tuesdays => false,
          :repeats_wednesdays => false,
          :repeats_thursdays => false,
          :repeats_fridays => false,
          :repeats_saturdays => false,
          :repeats_sundays => false,
          :repetition_vehicle_id => -1,
          :repetition_driver_id => 1,
          :repetition_interval => 1)
        RepeatingTrip.count.should == 0
      end

      it "should accept repeating trip values" do
        trip.repeats_mondays.should == true
        trip.repeats_tuesdays.should == false
        trip.repeats_wednesdays.should == false
        trip.repeats_thursdays.should == false
        trip.repeats_fridays.should == false
        trip.repeats_saturdays.should == false
        trip.repeats_sundays.should == false
        trip.repetition_vehicle_id.should == -1
        trip.repetition_driver_id.should == 1
        trip.repetition_interval.should == 1
      end

      it "should create a repeating trip when saved" do
        lambda {
          trip.save
          trip.repeating_trip.should_not be_nil
        }.should change(RepeatingTrip, :count).by(1)
        trip.repeating_trip_id.should_not be_nil
      end

      it "should instantiate trips for three weeks out" do
        trip.save
        r_id = trip.repeating_trip_id
        # The trip we just created, which is next week, plus 2 more
        Trip.where(:repeating_trip_id => r_id).count.should == 3
      end
    end
  end
end
