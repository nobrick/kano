module AdminScaffold
  module Filter
    class Eq < Filter::Base
      def type
        :eq
      end

      def view_display
        @options[:display]
      end
    end
  end
end
