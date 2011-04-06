# Load the rails application
require File.expand_path('../application', __FILE__)

TRIP_RESULT_CODES = {
  "COMP" => "Completed", # the trip was (as far as we know) completed
  "CANC" => "Cancelled", # the trip was cancelled by the customer
  "NS" => "No Show", # the customer did not show up for the trip
  "TD" => "Turndown", # the provider told the customer that it could not provide the trip
  "UNMET" => "Unmet Need" #a trip that was outside of the service parameters (too early, too late, too far, etc).
}

TRIP_PURPOSES = ["Life-Sustaining Medical", "Medical", "Nutrition", "Personal/Support Services", "Recreation", "Shopping", "School/Work", "Volunteer Work"]


# Initialize the rails application
Ridepilot::Application.initialize!
