module AdminScaffold
  module Field
    class DateTime < Field::Base
      def to_s
        @data.nil? ? "" : I18n.l(@data, format: :long)
      end
    end
  end
end
