module AdminScaffold::Attribute
  class DateTime < Base

    private

    def humanize_value(data)
      data.nil? ? "" : I18n.l(data, format: :long)
    end
  end
end
