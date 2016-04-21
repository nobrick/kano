module AdminScaffold
  module Field
    class Base
      attr_reader :data, :attribute
      def initialize(attribute, data, options = {})
        @attribute = attribute
        @data = data
        @options = options
      end
    end
  end
end
