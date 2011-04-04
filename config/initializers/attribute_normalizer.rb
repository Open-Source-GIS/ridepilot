AttributeNormalizer.configure do |config|

  config.normalizers[:titleize] = lambda do |value, options|
    value.is_a?(String) ? value.titleize : value
  end

  config.normalizers[:upcase] = lambda do |value, options|
    value.is_a?(String) ? value.upcase : value
  end

  config.normalizers[:squish] = lambda do |value, options|
    value.is_a?(String) ? value.strip.gsub(/\s+/, ' ') : value
  end


end

ActiveRecord::Base.send :include, AttributeNormalizer
