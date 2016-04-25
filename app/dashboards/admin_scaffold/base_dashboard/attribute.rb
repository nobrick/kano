module AdminScaffold
  class BaseDashboard
    class Attribute
      attr_reader :owner, :type
      def initialize(attr, owner, type, options = {})
        @attr = attr
        @owner = owner
        @type = type
        @options = options
        validate!
      end

      def partial_path
        if expand?
          return @options[:partial_path]
        else
          ''
        end
      end

      def expand?
        @type == Field::Expand
      end

      def data
        if @options.blank?
          @type
        else
          @type.with_options(@options)
        end
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
          raise "partial_path should be defiend"
        end
      end
    end
  end
end
