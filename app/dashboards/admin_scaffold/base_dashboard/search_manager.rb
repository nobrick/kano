module AdminScaffold
  class BaseDashboard::SearchManager
    attr_reader :search_path

    def initialize(attributes_manager, search_path)
      @attributes_manager = attributes_manager
      @search_path = search_path
      @predicates = []
    end

    def cont(attr_index)
      validate!(attr_index)
      predicate = "#{ attr_index.gsub(/\./, "_") }_cont"
      @predicates << predicate
      predicate
    end

    def eq(attr_index)
      validate!(attr_index)
      predicate = "#{ attr_index.gsub(/\./, "_") }_eq"
      @predicates << predicate
      predicate
    end

    def search_params(param)
      query = param.permit(q: search_view_predicate)[:q]
      return unless query
      value = query.values.first
      combinator = @predicates.map { |p| [ p, value ] }.to_h
      combinator.merge(m: 'or')
    end

    def search_view_predicate
      'id_eq'
    end

    private

    def validate!(attr_index)
      if !@attributes_manager.attr_defined?(attr_index)
        raise AdminScaffold::ArgumentError, "#{ attr_index }: not been defined"
      end
    end
  end
end
