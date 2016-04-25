module AdminScaffold
  module Field
    class String < Field::Base
      def to_s
        if i18n?
          I18n.t(@data, scope: i18n_scope)
        else
          @data
        end
      end

      private

      def i18n?
        !!@options[:i18n]
      end

      def attr_owner
        @options[:owner]
      end

      def i18n_scope
        raise 'I18n scope not defined' if attr_owner.blank?
        "#{attr_owner}.#{@attribute}"
      end
    end
  end
end
