module AdminScaffold
  class BaseDashboard
    class FiltersManager
      attr_reader :filter_path, :attributes_manager

      def initialize(attributes_manager ,filter_path)
        @attributes_manager = attributes_manager
        @filter_path = filter_path
        @filters = {}
      end

      def filter(attr_index)
        @filters[attr_index]
      end

      def filters
        @filters ||= @filters.values
      end

      def select(attr_index, options = {})
        define_filter(attr_index, Filter::Select, options)
      end

      def time_range(attr_index, options = {})
        define_filter(attr_index, Filter::TimeRange, options)
      end

      def range(attr_index, options = {})
        define_filter(attr_index, Filter::Range, options)
      end

      def radio(attr_index, options = {})
        define_filter(attr_index, Filter::Radio, options)
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
        predicates_from_user(conditions).each_pair do |attr_index, predicates|
          feedback_info << @filters[attr_index].feedback(predicates)
        end
        feedback_info
      end

      private

      def define_filter(attr_index, type, options = {})
        validate!(attr_index)
        attribute = @attributes_manager.attribute(attr_index)
        if type == Filter::TimeRange
          if attribute.type != Field::DateTime
            raise AdminScaffold::ArgumentError, "#{attr_index}: The attribute type should be DateTime"
          end
        end
        if type == Filter::Range
          if attribute.type != Field::Number
            raise AdminScaffold::ArgumentError, "#{attr_index}: The attribute type should be number"
          end
        end
        @filters[attr_index] = type.new(attribute, options)
      end

      def validate!(attr_index)
        if !attr_exist?(attr_index)
          raise AdminScaffold::ArgumentError, "#{attr_index}: The Attribute is not defined"
        end
        if @filters.has_key?(attr_index)
          raise AdminScaffold::ArgumentError, "#{attr_index}: You have defined a filter for this attribute"
        end
      end

      def attr_exist?(attr_index)
        @attributes_manager.attr_defined?(attr_index)
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
            value = c.value
            result[attr_name] ||= {}
            result[attr_name][predicate] = value
          end
        end
        result
      end

      def filter_condition?(condition)
        filter_predicates.include?(condition.key.to_sym)
      end

      def filter_predicates
        @filter_predicates ||= filters.map { |filter| filter.predicate }.flatten
      end
    end
  end
end
