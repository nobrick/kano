$ ->
  $('.js-modalShow')
    .on 'click', (event) ->
      event.preventDefault()
      link = $(event.target)
      target = link.data("target")
      modalId = link.data("target")
      $(modalId).modal('show')

