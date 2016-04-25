module AdminScaffold
  module Field
    class Deferred
      attr_reader :deferred_class, :options

      def initialize(deferred_class, options = {})
        @deferred_class = deferred_class
        @options = options
      end

      def new(*args)
        deferred_class.new(*args, options)
      end

      def ==(other)
        deferred_class == other
      end
    end
  end
end
