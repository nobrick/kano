module AdminScaffold::Attribute
  class Base
    def initialize(name, owner, options = {})
      @name = name
      @owner = onwer
      @options = options
    end

    def readable_name
      I18n.t @name, scope: [:activerecord, :attributes, "#{ @owner.underscore }"]
    end

    def data(resource, options = {})
      original_data = options.fetch(original_data, false)
      if original_data
        result = attr_data(resource)
      else
        result = resource
      end
      readable_result = readable_data(result)
      result_style = data_style(result)
      Data.new(readable_result, result_style)
    end

    def expand?
      false
    end

    private

    def data_style(data)
      styles[data]
    end

    def styles
      @options.fetch(:styles, {})
    end

    def readable_data(data)
      data
    end

    def attr_data(resource)
      data_methods.inject(resource) { |result, method| result.try(method) }
    end

    def data_methods
      @options.fetch(:methods, @name).split('.')
    end
  end
end
