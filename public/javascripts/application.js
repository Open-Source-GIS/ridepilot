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
		dateFormat: 'yy-mm-dd',
    showOn: "button",
    buttonImage: "/stylesheets/images/calendar-clock.png",
    buttonImageOnly: true,
    constrainInput: false
  });

  $('#new_monthly #monthly_start_date, #new_monthly #monthly_end_date').datepicker({
		dateFormat: 'yy-mm-dd'    		
  });


  var ISODateFormatToDateObject = function(str) {
    if(str === null) {
        return null;
    }

    var parts = str.split(' ');
    if(parts.length < 2) {
      return null;
    }
    
    var dateParts = parts[0].split('-'),
    timeSubParts = parts[1].split(':'),
    timeSecParts = timeSubParts[2].split('.'),
    timeHours = Number(timeSubParts[0]);

    _date = new Date();
    _date.setFullYear(Number(dateParts[0]));
    _date.setMonth(Number(dateParts[1])-1);
    _date.setDate(Number(dateParts[2]));
    _date.setHours(Number(timeHours));
    _date.setMinutes(Number(timeSubParts[1]));
    _date.setSeconds(Number(timeSecParts[0]));
    if (timeSecParts[1]) {
        _date.setMilliseconds(Number(timeSecParts[1]));
    }

    return _date;
  };

  $('#trip_pickup_time').change(function() {
    var pickupTimeDate = ISODateFormatToDateObject($('#trip_pickup_time').attr("value"));
    var appointmentTimeDate = ISODateFormatToDateObject($('#trip_appointment_time').attr("value"));
    var newPickupDate = new Date(pickupTimeDate.getTime() + (1000 * 60 * 30));    
    $('#trip_appointment_time').attr( "value", newPickupDate.format("yyyy-mm-dd HH:MM:ss"));
  });

});
