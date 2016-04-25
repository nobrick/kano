module AdminScaffold
  module Field
    class Number < Field::Base
      def to_s
        @data.to_s
      end
    end
  end
end
