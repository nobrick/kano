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
  $(".js-taxonCertifyFailReasonTrigger")
    .on 'change', () ->
      value = $(this).val()
      targetField = $(this).data('target')
      console.log(targetField)
      isDisabled = !!$(targetField).attr("visiability")
      if value == "failure"
        $(targetField).removeAttr("style")
      else if !isDisabled
        $(targetField).attr("style", "display: none")
