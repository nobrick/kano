module AdminScaffold
  module Field
    class Base
      attr_reader :attribute

      def self.with_params(attribute, options = {})
        Deferred.new(self, attribute, options)
      end

      def initialize(attribute, data, options = {})
        @attribute = attribute
        if options[:original_data]
          @data = data
        else
          @data = @attribute.data_methods.inject(data) { |result, method| result.try(method) }
        end
        @options = options
      end
    end
  end
end
