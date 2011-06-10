function ISODateFormatToDateObject(str) {
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
}

function supports_history_api() {
  return !!(window.history && history.pushState);
}

$(function() {

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

  $('#new_monthly #monthly_start_date, #new_monthly #monthly_end_date, input.datepicker').datepicker({
		dateFormat: 'yy-mm-dd'    		
  });
  
  var setAppointmentTime = function() {
    var pickupTimeDate = ISODateFormatToDateObject($('#trip_pickup_time').attr("value"));
    var appointmentTimeDate = new Date(pickupTimeDate.getTime() + (1000 * 60 * 30));    
    $('#trip_appointment_time').attr( "value", appointmentTimeDate.format("yyyy-mm-dd HH:MM"));
    
    return appointmentTimeDate;
  };
  
  var setWeek = function( dateTime ) {
    var calendar = $("#calendar");
    calendar.weekCalendar("gotoWeek", dateTime.getTime());
  };

  $('#trip_pickup_time').live('change', function() {
    var appointmentTime = setAppointmentTime();
    setWeek( appointmentTime );
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
    
  $("body.runs .wc-nav").click(function(e){
    var current_start, new_start, new_end;
    var target        = $(e.target);
    var week_nav      = $(this);
    
    if (target.hasClass("wc-today")){
      current_start   = new Date(parseInt(week_nav.attr("data-current-week-start")));
      new_start       = new Date(current_start.getTime());
      new_end         = new Date(current_start.getTime());
      new_end.setDate(new_end.getDate() + 7);
    } else {
      current_start = new Date(parseInt(week_nav.attr("data-start-time")));
      new_start     = new Date(current_start.getTime());
      new_end       = new Date(current_start.getTime());
      
      if (target.hasClass("wc-prev")) {
        new_start.setDate(new_start.getDate() - 7); 
        new_end = current_start;
      } else {
        new_start.setDate(new_start.getDate() + 7); 
        new_end.setDate(new_end.getDate() + 14);
      }
    }

    $.get(window.location.href, {
      start : new_start.getTime(),
      end : new_end.getTime()
    }, function(data) {
      $("#runs tr").not(".head").remove();
      $("#runs").append(data.rows.join(""));
      week_nav.attr("data-start-time", new_start.getTime());
      $("#start_date").html((new_start.getMonth()+1) + "-" + new_start.getDate() + "-" + new_start.getFullYear());
      $("#end_date").html((new_end.getMonth()+1) + "-" + new_end.getDate() + "-" + new_end.getFullYear());  
    }, "json");
    
  });
  
});
