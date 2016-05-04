module AdminScaffold
  module Filter
    class Base
      extend Forwardable
      def_delegators :@attribute, :name

      def initialize(attribute, options = {})
        @attribute = attribute
        @options = options
      end

      def values
        @options[:values].map do |value|
          [@attribute.data(true).new(value).to_s, value]
        end.to_h
      end

      def predicate
        "#{ @attribute.attr }_eq".to_sym
      end

      def feedback(predicate_value_pair)
        value = predicate_value_pair["eq"]
        "#{ @attribute.name }: #{ @attribute.data(true).new(value) }"
      end
    end
  end
end
