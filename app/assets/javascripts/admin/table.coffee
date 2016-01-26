$ ->
  $('.js-table')
    .on 'click', 'tbody tr', (event) ->
      target = $(event.target)
      tr = $(event.target).closest("tr")
      isSame = (i, ele) ->
        target.is(ele)
      if tr.find('.js-table-nolink').filter(isSame).length == 0
        if (tr.data("url") != undefined) && (tr.data("url") != "")
          window.location = tr.data("url")
