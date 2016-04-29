module AdminScaffold
  class BaseDashboard
    class AttributesManager
      attr_reader :resource_class, :attributes
      def initialize(resource_class)
        @resource_class = resource_class
        @attributes = {}
      end

      def string(attr_index, options = {})
        define_attribute(attr_index, Field::String, options)
      end

      def date_time(attr_index, options = {})
        define_attribute(attr_index, Field::DateTime, options)
      end

      def number(attr_index, options = {})
        define_attribute(attr_index, Field::Number, options)
      end

      def expand(attr_index, options = {})
        define_attribute(attr_index, Field::Expand, options)
      end

      def attr_name(attr_index)
        @attributes[attr_index].name
      end

      def attribute(attr_index)
        @attributes.fetch(attr_index)
      end

      def attr_defined?(attr_index)
        @attributes.has_key?(attr_index)
      end

      private

      def define_attribute(attr_index, type, options = {})
        validate!(attr_index)
        attr_owner = options.delete(:owner) || @resource_class
        @attributes[attr_index] = Attribute.new(original_attr(attr_index), attr_owner, type, options)
      end

      def original_attr(attr)
        if !(attr =~ /\./)
          attr
        else
          attr.split('.')[-1]
        end
      end

      def attr_owner(attr)
        @attributes[attr][:attr_owner]
      end

      def validate!(attr)
        if attr_defined?(attr)
          raise "This attribute has been defiend"
        end
      end
    end
  end
end
