module AdminScaffold
  module Field
    class Deferred
      attr_reader :deferred_class, :options

      def initialize(deferred_class, attribute, options = {})
        @deferred_class = deferred_class
        @attribute = attribute
        @options = options
      end

      def new(*args)
        deferred_class.new(@attribute, *args , @options)
      end

      def ==(other)
        deferred_class == other
      end
    end
  end
end
