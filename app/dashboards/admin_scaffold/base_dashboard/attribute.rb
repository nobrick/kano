module AdminScaffold
  class BaseDashboard
    class Attribute
      attr_reader :owner, :type, :attr_text
      def initialize(attr, owner, type, options = {})
        @attr_text = attr
        @owner = owner
        @type = type
        @options = options
        validate!
      end

      def partial_path
        if expand?
          @options[:partial_path] + "/#{ @owner.downcase }_" + "#{ @attr_text }_table_header"
        else
          ''
        end
      end

      def data_methods
        (@options[:methods] || @attr_text).split('.')
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
          I18n.t @attr_text, scope: [:activerecord, :attributes, "#{ @owner.underscore }"]
        end
      end

      private

      def validate!
        if expand? && @options[:partial_path].blank?
          raise "partial_path should be defiend"
        end
      end
    end
  end
end
