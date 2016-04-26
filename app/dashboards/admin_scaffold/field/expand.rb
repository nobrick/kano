module AdminScaffold
  module Field
    class Expand < Field::Base
      def initialize(attribute, options = {})
        @attribute = attribute
        @options = options
      end

      def partial_path
        @options[:partial_path] + "/#{ @attribute.attr_text }_table_data"
      end
    end
  end
end
