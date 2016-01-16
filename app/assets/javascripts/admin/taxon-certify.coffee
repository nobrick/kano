$ ->
  pageIdentifier = "#admin-handymen-certifications-index "
  $(pageIdentifier + '#certifyFailModal')
    .on 'show.bs.modal', (event) ->
      button = $(event.relatedTarget)
      failCode = button.data('failcode')
      failMsg = button.data('failmsg')
      url = button.data('url')

      modal = $(this)
      modal.find('.certifyFail').attr("action", url)
      modal.find('textarea').val(failMsg)
      modal.find('select').val(failCode)

$ ->
  pageIdentifier = "#admin-handymen-certifications-index "
  $(pageIdentifier + 'table')
    .on 'click', 'tbody tr', (event) ->
      target = $(event.target)
      td = $(event.target).closest("td")
      tr = $(event.target).closest("tr")
      lastTd = tr.find('td:last-child')
      if !td.is(lastTd)
        window.location = tr.data("url")



