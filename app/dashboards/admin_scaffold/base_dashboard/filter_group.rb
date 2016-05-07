module AdminScaffold
  class BaseDashboard::FilterGroup
    def initialize(attributes_manager, options = {})
      @attributes_manager = attributes_manager
      @options = options
      @filters = {}
    end

    def name
      @options[:name] || "筛选"
    end

    def filter(filter_index)
      @filters[filter_index]
    end

    def has_filter?(filter_index)
      @filters.has_key?(filter_index)
    end

    def filters
      @filter_values ||= @filters.values
    end

    def type
      @options[:type] || :modal
    end

    def predicates
      @predicates ||= @filters.values.map { |filter| filter.predicate }.flatten
    end

    def eq(attr_index, options = {})
      define_filter(attr_index, Filter::Eq, options)
    end

    def time_range(attr_index, options = {})
      define_filter(attr_index, Filter::TimeRange, options)
    end

    def range(attr_index, options = {})
      define_filter(attr_index, Filter::Range, options)
    end

    def time_interval_gt(attr_index, options = {})
      define_filter(attr_index, Filter::TimeIntervalGt, options)
    end

    private

    def define_filter(attr_index, type, options)
      validate!(attr_index, type)
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
      filter = type.new(attribute, options)
      filter_index = attr_index + type.index_suffix
      @filters[filter_index] = type.new(attribute, options)
    end

    def validate!(attr_index, type)
      if !attr_exist?(attr_index)
        raise AdminScaffold::ArgumentError, "#{attr_index}: The Attribute is not defined"
      end
      filter_index = attr_index + type.index_suffix
      if @filters.has_key?(filter_index)
        raise AdminScaffold::ArgumentError, "#{attr_index}: You have defined a same type of filter in this group"
      end
    end

    def attr_exist?(attr_index)
      @attributes_manager.attr_defined?(attr_index)
    end
  end
end
