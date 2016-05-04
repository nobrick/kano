module AdminScaffold
  class BaseDashboard
    class Attribute
      attr_reader :owner, :type, :attr

      def initialize(attr, owner, type, options = {})
        @attr = attr
        @owner = owner
        @type = type
        @options = options
        validate!
      end

      def partial_path
        if expand?
          @options[:partial_path] + "/#{ @owner.downcase }_" + "#{ @attr }_table_header"
        else
          ''
        end
      end

      def data_methods
        (@options[:methods] || @attr).split('.')
      end

      def expand?
        @type == Field::Expand
      end

      def data(original_data = false)
        @options[:original_data] = original_data
        @type.with_params(self, @options)
      end

      def name
        if expand?
          ''
        else
          I18n.t @attr, scope: [:activerecord, :attributes, "#{ @owner.underscore }"]
        end
      end

      private

      def validate!
        if expand? && @options[:partial_path].blank?
          raise AdminScaffold::ArgumentError, "partial_path should be defined"
        end
      end
    end
  end
end
