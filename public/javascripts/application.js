// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

  $("tr:odd").addClass("odd");

  // add time picker functionality
  // http://trentrichardson.com/examples/timepicker/
  $('#trip_pickup_time, #trip_appointment_time').datetimepicker({
  	ampm: false,
  	hourMin: 8,
  	hourMax: 18,
		hourGrid: 3,
    	minuteGrid: 15,
		timeFormat: 'hh:mm:ss',
		dateFormat: 'yy-mm-dd'    		
  });

  $('#new_monthly #monthly_start_date, #new_monthly #monthly_end_date').datepicker({
		dateFormat: 'yy-mm-dd'    		
  });

});
