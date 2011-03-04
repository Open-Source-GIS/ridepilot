module ApplicationHelper

  def format_newlines(text)
    return text.gsub("\n", "<br/>")
  end
end
