module AdminScaffold
  module Filter
    class TimeRange < Filter::Base
      def type
        :time_range
      end

      def predicate
        attr_text = @attribute.attr
        [(attr_text + "_date_gteq").to_sym, (attr_text + "_date_lteq").to_sym]
      end

      def gt_predicate
        attr_text = @attribute.attr
        (attr_text + "_date_gteq").to_sym
      end

      def lt_predicate
        attr_text = @attribute.attr
        (attr_text + "_date_lteq").to_sym
      end

      def feedback(predicate_value_pair)
        attr_name = @attribute.name
        gteq_value = predicate_value_pair["date_gteq"]
        lteq_value = predicate_value_pair["date_lteq"]
        if !gteq_value.blank? && !lteq_value.blank?
          attr_name + ": " + gteq_value.to_s + " ~ " + lteq_value.to_s
        elsif !gteq_value.blank? && lteq_value.blank?
          attr_name + ": >= "+ gteq_value.to_s
        elsif gteq_value.blank? && !lteq_value.blank?
          attr_name + ": <= "+ lteq_value.to_s
        end
      end
    end
  end
end
