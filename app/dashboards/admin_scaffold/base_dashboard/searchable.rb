module AdminScaffold
  class BaseDashboard
    module Searchable
      SEARCH_PATH_HELPER = nil
      SEARCH_PREDICATES = []

      def search_params(param)
        query = param.permit(q: search_view_predicate)[:q]
        return unless query
        value = query.values.first
        combinator = search_predicates.map { |p| [ p, value ] }.to_h
        combinator.merge(m: 'or')
      end

      def search_view_predicate
        'id_eq'
      end

      def have_search?
        !self.class::SEARCH_PREDICATES.empty?
      end

      def search_path
        self.class::SEARCH_PATH_HELPER
      end

      private

      def search_predicates
        self.class::SEARCH_PREDICATES
      end
    end
  end
end
