class AdminValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    passed = if options.fetch :presence, false
               value && value.admin?
             else
               value.nil? || value.admin?
             end
    message = options[:message] || '拒绝访问'
    strict_option = { strict: options[:strict] }
    record.errors.add(attribute, message, strict_option) unless passed
  end
end
