module AdminScaffold::Attribute
  class Expand
    def initialize(name, owner, options = {})
      @name = name
      @owner = owner
      @options = options
      validate!
    end

    def readable_name
      @options.fetch(:header, '')
    end

    def expand_header?
      !!@options.fetch(:header, false)
    end

    def partial_path
      @options[:partial_path] + "/#{ @owner.underscore }_" + "#{ @attr }_table_header"
    end

    def data_partial_path
      @options[:partial_path] + "/#{ @owner.underscore }_" +  "#{ @attr }_table_data"
    end

    def expand?
      true
    end

    private

    def validate!
      if @options[:partial_path].blank?
        raise AdminScaffold::ArgumentError, "partial_path should be defined"
      end
    end
  end
end
