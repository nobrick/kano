module AdminScaffold
  module Filter
    class TimeIntervalGt < Filter::Base
      def self.index_suffix
        "_time_interval_gt"
      end

      def type
        :time_interval_gt
      end

      def predicate
        "#{ @attribute.name }_time_interval_gt".to_sym
      end

      def feedback(predicate_value_pair)
        value = predicate_value_pair["time_interval_gt"]
        "#{ @attribute.humanize_name }: <=#{ @attribute.data(value, original_data: true) }"
      end
    end
  end
end
