module Rails3JQueryAutocomplete

  # Contains utility methods used by autocomplete
  module Helpers

    def get_autocomplete_items(parameters)
      model = parameters[:model]
      method = parameters[:method]
      options = parameters[:options]
      term = parameters[:term]
      is_full_search = options[:full]

      limit = get_autocomplete_limit(options)
      implementation = get_implementation(model)
      order = get_autocomplete_order(implementation, method, options)

      case implementation
        when :mongoid
          search = (is_full_search ? '.*' : '^') + term + '.*'
          items = model.where(method.to_sym => /#{search}/i).limit(limit).order_by(order)
        when :activerecord
        query = "#{(is_full_search ? '%' : '')}#{term.downcase}%"
        if method == "first_name"
          items = model.where(["LOWER(first_name || ' ' || middle_initial || ' ' || last_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(last_name || ', ' || first_name) LIKE ? ", query, query, query]) \
            .limit(limit).order(order)
        else
          items = model.where(["LOWER(#{method}) LIKE ?", query]) \
            .limit(limit).order(order)
        end

      end
    end
  end
end
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Ridepilot::Application.initialize!
