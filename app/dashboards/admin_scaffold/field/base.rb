module AdminScaffold
  module Field
    class Base
      attr_reader :data, :attribute

      def self.with_params(attribute, options = {})
        Deferred.new(self, attribute, options)
      end

      def initialize(attribute, resource, options = {})
        @attribute = attribute
        @data = @attribute.data_methods.inject(resource) { |result, method| result.try(method) }
        @options = options
      end
    end
  end
end
