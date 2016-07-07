module AdminScaffold::BaseDashboard
  class Data
    attr_reader :style
    def initialize(data, style = nil)
      @data = data
      set_style
    end

    def to_s
      @data
    end

    def has_style?
      !!@style
    end

    private

    def set_style(style)
      if valid_style?(style)
        @style = style
      else
        @style = :default
      end
    end

    def valid_style?(style)
      %i{default primary success info warning danger}.include?(style)
    end
  end
end
