module AdminScaffold
  module Field
    class Expand < Field::Base
      def partial_path
        @options[:partial_path]
      end
    end
  end
end
