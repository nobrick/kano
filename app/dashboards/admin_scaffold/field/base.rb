module AdminScaffold
  module Field
    class Base
      attr_reader :attribute

      def self.with_params(attribute, options = {})
        Deferred.new(self, attribute, options)
      end

      def initialize(attribute, data, options = {})
        @attribute = attribute
        @options = options
        set_data(data)
      end

      private

      def set_data(data)
        if @options[:original_data]
          @data = data
        else
          @data = @attribute.data_methods.inject(data) { |result, method| result.try(method) }
        end
      end
    end
  end
end
