module ApplicationHelper

  def format_newlines(text)
    return text.gsub("\n", "<br/>")
  end

  def link_to_with_highlight(name, options = {}, html_options = {}) # same sig as #link_to
    html_options.merge!({ :class => 'active' }) if current_page?(options)
    link_to(name, options, html_options)
  end

end
