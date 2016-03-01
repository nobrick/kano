$ ->
  $('#js-addressEdit')
    .on 'show.bs.modal', (event) ->
      button = $(event.relatedTarget)
      cityCode = button.data('city-code')
      districtCode = button.data('district-code')
      content = button.data('content')
      url = button.data('url')

      modal = $(this)
      selects = modal.find('.city-select')
      $("option:gt(0)", selects).remove()
      if cityCode and districtCode

        $.get "/china_city/430000", (data) ->
          data = data.data if data.data?
          selects[0].options.add(new Option(option[0], option[1])) for option in data
          $(selects[0]).val(cityCode)

        $.get "/china_city/#{cityCode}", (data) ->
          data = data.data if data.data?
          selects[1].options.add(new Option(option[0], option[1])) for option in data
          $(selects[1]).val(districtCode)

        modal.find('textarea').val(content)
        modal.find('form').attr('action', url)
