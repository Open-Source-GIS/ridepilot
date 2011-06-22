module ApplicationHelper
  
  def display_trip_result(trip_result)
    TRIP_RESULT_CODES[trip_result] || "Unscheduled"
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
