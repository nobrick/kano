module AdminScaffold
  class BaseDashboard
    class FiltersManager
      extend Forwardable
      def_delegators "@filter_groups[:default]", :time_range, :range, :eq, :time_interval_gt

      attr_reader :filter_path, :attributes_manager, :filter_groups

      def initialize(attributes, filter_path)
        @attributes= attributes
        @filter_path = filter_path
        @filter_groups = { default: FiltersGroup.new(@attributes) }
      end

      def filter_group(group_index, options = {})
        new_group = FiltersGroup.new(@attributes, options)
        @filter_groups[group_index] = new_group
        yield new_group
      end

      def filter_groups
        @filter_group_values ||= @filter_groups.values
      end

      def has_feedback?(ransack_search)
        ransack_search.conditions.any? do |c|
          filter_predicates.include?(c.key.to_sym)
        end
      end

      def filter_params(param)
        query = param.permit(q: filter_predicates)[:q]
        return unless query
        query.merge(m: 'and')
      end

      def feedback(ransack_search)
        conditions = ransack_search.conditions
        feedback_info = []
        predicates_from_user(conditions).each_pair do |filter_index, predicates|
          group = filter_groups.find { |group| group.has_filter?(filter_index) }
          feedback_info << group.filter(filter_index).feedback(predicates)
        end
        feedback_info
      end

      private

      def filter_index_suffix(predicate)
        case predicate
        when "gteq", "lteq"
          "_range"
        when "date_gteq", "date_lteq"
          "_time_range"
        when "eq"
          "_eq"
        when "time_interval_gt"
          "_time_interval_gt"
        end
      end

      # only the filter predicate is allowed to return
      # return:
      #   {
      #     attr1 => { predicate1 => value1, predicate2 => value2},
      #     attr2 => { predicate3 => value3 },
      #      ..
      #   }
      def predicates_from_user(conditions)
        result = {}
        conditions.each do |c|
          if filter_condition?(c)
            names = c.attributes.map { |attr| attr.name }
            attr_name = names.join("_or_")
            predicate = c.predicate_name
            filter_index = attr_name + filter_index_suffix(predicate)
            value = c.formatted_values_for_attribute(c.attributes.first)
            result[filter_index] ||= {}
            result[filter_index][predicate] = value
          end
        end
        result
      end

      def filter_condition?(condition)
        filter_predicates.include?(condition.key.to_sym)
      end

      def filter_predicates
        @filter_predicates ||= @filter_groups.values.map { |group| group.predicates }.flatten.uniq
      end
    end
  end
end
