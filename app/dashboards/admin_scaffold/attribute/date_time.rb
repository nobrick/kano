module AdminScaffold::Attribute
  class DateTime < Base

    private

    def readable_data(data)
      data.nil? ? "" : I18n.l(data, format: :long)
    end
  end
end
