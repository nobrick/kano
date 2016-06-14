module AdminScaffold
  module Field
    class String < Field::Base
      def to_s
        if @data && i18n?
          I18n.t(@data.downcase, scope: i18n_scope)
        else
          @data
        end
      end

      private

      def i18n?
        !!@options[:i18n]
      end

      def i18n_scope
        "#{@attribute.owner.underscore}.#{@attribute.attr.pluralize}"
      end
    end
  end
end
