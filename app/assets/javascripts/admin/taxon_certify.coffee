$ ->
  $('#certifyFailModal')
    .on 'show.bs.modal', (event) ->
      button = $(event.relatedTarget)
      failCode = button.data('failcode')
      failMsg = button.data('failmsg')
      url = button.data('url')

      modal = $(this)
      modal.find('.certifyFail').attr("action", url)
      modal.find('textarea').val(failMsg)
      modal.find('select').val(failCode)

