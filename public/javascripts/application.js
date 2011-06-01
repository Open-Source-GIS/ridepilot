// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

  $("tr:odd").addClass("odd");

  // hide middle/last names for group customer
  var updateGroupField = function() {
    if ( $('input#customer_group').is(':checked') ){
      $('li.middlename, li.lastname').hide();
      $('li.firstname label').html("Group Name:");
    } else {
      $('li.middlename, li.lastname').show();
      $('li.firstname label').html("First Name:");
    }
  };
  updateGroupField();
  $('input#customer_group').click(updateGroupField);

  // add time picker functionality
  // http://trentrichardson.com/examples/timepicker/
  $('#trip_pickup_time, #trip_appointment_time').datetimepicker({
  	ampm: false,
  	hourMin: 8,
  	hourMax: 18,
		hourGrid: 3,
  	minuteGrid: 15,
		timeFormat: 'hh:mm',
		dateFormat: 'yy-mm-dd',
    showOn: "button",
    buttonImage: "/stylesheets/images/calendar-clock.png",
    buttonImageOnly: true,
    constrainInput: false
  });

  $('#new_monthly #monthly_start_date, #new_monthly #monthly_end_date, input.datepicker').datepicker({
		dateFormat: 'yy-mm-dd'    		
  });

  var ISODateFormatToDateObject = function(str) {
    if(str === null) return null;

    var parts = str.split(' ');
    if(parts.length < 2) return null;
    
    var dateParts = parts[0].split('-'),
    timeSubParts = parts[1].split(':'),
    timeHours = Number(timeSubParts[0]);

    _date = new Date();
    _date.setFullYear( Number(dateParts[0]), (Number(dateParts[1])-1), Number(dateParts[2]) );
    _date.setHours(Number(timeHours), Number(timeSubParts[1]), 0, 0);
    
    return _date;
  };
  
  var setAppointmentTime = function() {
    var pickupTimeDate = ISODateFormatToDateObject($('#trip_pickup_time').attr("value"));
    var appointmentTimeDate = new Date(pickupTimeDate.getTime() + (1000 * 60 * 30));    
    $('#trip_appointment_time').attr( "value", appointmentTimeDate.format("yyyy-mm-dd HH:MM"));
    
    return appointmentTimeDate;
  };
  
  var setCurrentWeek = function( dateTime ) {
    var calendar = $("#calendar");
    calendar.weekCalendar("gotoWeek", dateTime.getTime());
  };

  $('#trip_pickup_time').change(function() {
    var appointmentTime = setAppointmentTime();
    setCurrentWeek( appointmentTime );
  });
  
  $('#new_trip #customer_name').bind('railsAutocomplete.select', function(e){ 
    if ($("#trip_group").val() == "true") {
      $("li.passengers").hide();
      $("li.group_size").show();
    } else {
      $("li.passengers").show();
      $("li.group_size").hide();
    } 
  });
  
  $("#new_customer[data-path]").live("click", function(e) {
    window.location = $(this).attr("data-path") + "?customer_name=" + $("#customer_name").val();
  });
  
});
