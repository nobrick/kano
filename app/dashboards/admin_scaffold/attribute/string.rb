module AdminScaffold::Attribute
  class String < Base

    private

    def humanize_value(data)
      if data && i18n?
        I18n.t(data.downcase, scope: i18n_scope)
      else
        data
      end
    end

    def i18n?
      @options.fetch(:i18n, false)
    end

    def i18n_scope
      "#{ @owner.underscore }.#{ @name.pluralize }"
    end
  end
end
