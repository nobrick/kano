module AdminScaffold
  class BaseDashboard
    class Attributes
      attr_reader :resource_class, :attributes
      def initialize(resource_class)
        @resource_class = resource_class
        @attributes = {}
      end

      def string(attr_index, options = {})
        define_attribute(attr_index, 'string', options)
      end

      def date_time(attr_index, options = {})
        define_attribute(attr_index, 'date_time', options)
      end

      def number(attr_index, options = {})
        define_attribute(attr_index, 'number', options)
      end

      def expand(attr_index, options = {})
        define_attribute(attr_index, 'expand', options)
      end

      def attribute(attr_index)
        @attributes.fetch(attr_index)
      end

      def attr_defined?(attr_index)
        @attributes.has_key?(attr_index)
      end

      private

      def define_attribute(attr_index, type, options = {})
        attr_class = const_get("attribute/#{ type }".camelize)
        validate!(attr_index)
        owner = options.fetch(:owner, @resource_class)
        name = original_attr(attr_index)
        @attributes[attr_index] = attr_class.new(name, owner, options)
      end

      def original_attr(attr)
        if !(attr =~ /\./)
          attr
        else
          attr.split('.')[-1]
        end
      end

      def validate!(attr)
        if attr_defined?(attr)
          raise AdminScaffold::ArgumentError, "#{ attr }: has been defined"
        end
      end
    end
  end
end
