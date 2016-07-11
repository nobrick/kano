module AdminScaffold
  class BaseDashboard
    class Attributes
      attr_reader :resource_class, :attributes
      def initialize(resource_class)
        @resource_class = resource_class
        @attributes = {}
      end

      def string(attr_index, options = {})
        define_attribute(attr_index, Attribute::String, options)
      end

      def date_time(attr_index, options = {})
        define_attribute(attr_index, Attribute::DateTime, options)
      end

      def number(attr_index, options = {})
        define_attribute(attr_index, Attribute::Number, options)
      end

      def expand(attr_index, options = {})
        define_attribute(attr_index, Attribute::Expand, options)
      end

      def all
        @attributes.values
      end

      def [](attr_index)
        @attributes.fetch(attr_index)
      end

      def has_defined?(attr_index)
        @attributes.has_key?(attr_index)
      end

      private

      def define_attribute(attr_index, type, options = {})
        validate!(attr_index)
        owner = options.fetch(:owner, @resource_class)
        name = attr_name(attr_index)
        @attributes[attr_index] = type.new(name, owner, options)
      end

      def attr_name(attr)
        if !(attr =~ /\./)
          attr
        else
          attr.split('.')[-1]
        end
      end

      def validate!(attr)
        if has_defined?(attr)
          raise AdminScaffold::ArgumentError, "#{ attr }: has been defined"
        end
      end
    end
  end
end
