$ ->
  pageIdentifier = "#admin-finance-withdrawals-transfer-index "
  $(pageIdentifier + '#js-transferFailModal')
    .on 'show.bs.modal', (event) ->
      button = $(event.relatedTarget)
      id = button.data('id')
      failMsg = button.data('failmsg')
      url = button.data('url')
      taxon = button.data('taxon')
      total = button.data('total')
      name = button.data('name')
      total += " 元"

      modal = $(this)
      modal.find('.js-transferFail').attr("action", url)
      modal.find('.js-transferFail-name').html(name)
      modal.find('.js-transferFail-total').html(total)
      modal.find('.js-transferFail-id').html(id)
