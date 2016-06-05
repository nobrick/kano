module AdminScaffold
  module Field
    class Expand < Field::Base
      def initialize(attribute, options = {})
        @attribute = attribute
        @options = options
      end
    end
  end
end
