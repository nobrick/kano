module AdminScaffold
  module Field
    class Base
      attr_reader :data, :attribute

      def self.with_options(options = {})
        Deferred.new(self, options)
      end

      def initialize(attribute, data, options = {})
        @attribute = attribute
        @data = data
        @options = options
      end
    end
  end
end
