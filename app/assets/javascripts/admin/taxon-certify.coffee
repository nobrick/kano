$ ->
  pageIdentifier = "#admin-handymen-certifications-index "
  $(pageIdentifier + '#js-certifyFailModal')
    .on 'show.bs.modal', (event) ->
      button = $(event.relatedTarget)
      failCode = button.data('failcode')
      failMsg = button.data('failmsg')
      url = button.data('url')
      taxon = button.data('taxon')
      handyman = button.data('handyman')

      modal = $(this)
      modal.find('.js-certifyFail').attr("action", url)
      modal.find('textarea').val(failMsg)
      modal.find('select').val(failCode)
      modal.find('.js-certifyFail-name').html(handyman)
      modal.find('.js-certifyFail-taxon').html(taxon)

$ ->
  pageIdentifier = "#admin-handymen-certifications-index "
  $(pageIdentifier + 'table')
    .on 'click', 'tbody tr', (event) ->
      target = $(event.target)
      tr = $(event.target).closest("tr")
      nolinks = tr.find('.js-nolink')
      if !(target.is(nolinks[0]) || target.is(nolinks[1]) || target.is(nolinks[2]))
        window.location = tr.data("url")



