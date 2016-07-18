module AdminScaffold::Attribute
  class Expand
    def initialize(name, owner, options = {})
      @name = name
      @owner = owner
      @options = options
      validate!
    end

    def humanize_name
      @options.fetch(:header, '')
    end

    def expand_header?
      @options.fetch(:expand_header, false)
    end

    def header_partial_path
      if expand_header?
        @options[:partial_path] + "/#{ @owner.underscore }_" + "#{ @name }_table_header"
      else
        ""
      end
    end

    def data_partial_path
      @options[:partial_path] + "/#{ @owner.underscore }_" +  "#{ @name }_table_data"
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
