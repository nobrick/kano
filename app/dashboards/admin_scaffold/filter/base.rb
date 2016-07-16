module AdminScaffold
  module Filter
    class Base
      extend Forwardable
      def_delegators :@attribute, :humanize_name

      def self.index_suffix
        "_eq"
      end

      def initialize(attribute, options = {})
        @attribute = attribute
        @options = options
      end

      def values
        @options[:values].map do |value|
          [@attribute.data(value, original_data: true).to_s, value]
        end.to_h
      end

      def default_value
        @options[:default_value]
      end

      def predicate
        "#{ @attribute.name }_eq".to_sym
      end

      def feedback(predicate_value_pair)
        value = predicate_value_pair["eq"]
        "#{ @attribute.humanize_name }: #{ @attribute.data(value, original_data: true) }"
      end
    end
  end
end
