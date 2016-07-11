module AdminScaffold
  module Filter
    class Range < Filter::Base
      def self.index_suffix
        "_range"
      end

      def type
        :range
      end

      def predicate
        attr_text = @attribute.name
        [(attr_text + "_gteq").to_sym, (attr_text + "_lteq").to_sym]
      end

      def gt_predicate
        attr_text = @attribute.name
        (attr_text + "_gteq").to_sym
      end

      def lt_predicate
        attr_text = @attribute.name
        (attr_text + "_lteq").to_sym
      end

      def feedback(predicate_value_pair)
        attr_name = @attribute.humanize_name
        gteq_value = predicate_value_pair["gteq"]
        lteq_value = predicate_value_pair["lteq"]
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
