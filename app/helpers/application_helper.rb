module ApplicationHelper
  
  def display_trip_result(trip_result)
    TRIP_RESULT_CODES[trip_result] || "Unscheduled"
  end
  
  def format_time_for_listing(time)
    time.strftime('%A ') +
    time.strftime('%I:%M%P').gsub(/^0/,'').gsub(/m$/,'') +
    time.strftime(' %m-%d-%Y')
  end
  
  def format_date_for_daily_manifest(date)
    date.strftime('%A, %m-%d-%Y')
  end
  
  def format_trip_for_daily_manifest(trip)
    <<-HTML
      #{trip.customer.name}<span class='address_separator'></span>
      #{trip.customer.phone_number_1}<span class='address_separator'></span>
      #{trip.customer.phone_number_2}
      <br/>
      #{trip.pickup_address.text}<span class='address_separator'></span>
      #{trip.dropoff_address.text}
    HTML
  end
  
  def delete_trippable_link(trippable)
    if can? :destroy, trippable
      link_to trippable.trips.present? ? 'Duplicate' : 'Delete', trippable, :class => 'delete'
    end
  end
  
  def can_delete?(trippable)
    trippable.trips.blank? && can?( :destroy, trippable )
  end
  
  def format_newlines(text)
    return text.gsub("\n", "<br/>")
  end

  def bodytag_class
    a = controller.class.to_s.underscore.gsub(/_controller$/, '')
    b = controller.action_name.underscore
    "#{a} #{b}".gsub(/_/, '-')
  end

  def collect_weekdays(schedule)
    weekdays = []
    if schedule.monday
      weekdays.push :monday
    end
    if schedule.tuesday
      weekdays.push :tuesday
    end
    if schedule.wednesday
      weekdays.push :wednesday
    end
    if schedule.thursday
      weekdays.push :thursday
    end
    if schedule.friday
      weekdays.push :friday
    end
    if schedule.saturday
      weekdays.push :saturday
    end
    if schedule.sunday
      weekdays.push :sunday
    end
    return weekdays
  end

  def weekday_abbrev(weekday)
    weekday_abbrevs = {
      :monday => 'M',
      :tuesday => 'T',
      :wednesday => 'W',
      :thursday => 'R',
      :friday => 'F',
      :saturday => 'S',
      :sunday => 'U'
    }

    return weekday_abbrevs[weekday]
  end
end
