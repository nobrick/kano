module AdminScaffold::Attribute
  class Base
    attr_reader :name, :owner

    def initialize(name, owner, options = {})
      @name = name
      @owner = owner
      @options = options
    end

    def humanize_name
      I18n.t @name, scope: [:activerecord, :attributes, "#{ @owner.underscore }"]
    end

    def data(resource, options = {})
      original_data = options.fetch(:original_data, false)
      if original_data
        result = resource
      else
        result = attr_value(resource)
      end
      humanize_result = humanize_value(result)
      result_style = value_style(result)
      ::AdminScaffold::BaseDashboard::AttributeData.new(humanize_result, result_style)
    end

    def expand?
      false
    end

    private

    def value_style(data)
      styles[data]
    end

    def styles
      @options.fetch(:styles, {})
    end

    def humanize_value(data)
      data
    end

    def attr_value(resource)
      data_methods.inject(resource) { |result, method| result.try(method) }
    end

    def data_methods
      @options.fetch(:methods, @name).split('.')
    end
  end
end
