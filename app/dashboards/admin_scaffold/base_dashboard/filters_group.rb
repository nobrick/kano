module AdminScaffold
  class BaseDashboard::FiltersGroup
    def initialize(attributes, options = {})
      @attributes = attributes
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

    def link_params
      result = {}
      filters.each do |filter|
        result[filter.predicate] = filter.default_value
      end
      result
    end

    def predicates
      @predicates ||= @filters.values.map { |filter| filter.predicate }.flatten
    end

    def eq(attr_index, options = {})
      validate!(attr_index, Filter::Eq)
      define_filter(attr_index, Filter::Eq, options)
    end

    def time_range(attr_index, options = {})
      validate!(attr_index, Filter::TimeRange)
      attribute = @attributes[attr_index]
      if attribute.class != Attribute::DateTime
        raise AdminScaffold::ArgumentError, "#{attr_index}: The attribute type should be DateTime"
      end
      define_filter(attr_index, Filter::TimeRange, options)
    end

    def range(attr_index, options = {})
      validate!(attr_index, Filter::Range)
      attribute = @attributes[attr_index]
      if attribute.class != Attribute::Number
        raise AdminScaffold::ArgumentError, "#{attr_index}: The attribute type should be number"
      end
      define_filter(attr_index, Filter::Range, options)
    end

    def time_interval_gt(attr_index, options = {})
      validate!(attr_index, Filter::TimeIntervalGt)
      define_filter(attr_index, Filter::TimeIntervalGt, options)
    end

    private

    def define_filter(attr_index, type, options)
      attribute = @attributes[attr_index]
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
      @attributes.has_defined?(attr_index)
    end
  end
end
