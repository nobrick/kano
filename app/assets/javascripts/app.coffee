@PingppPayment =
  create: ->
    return unless gon?.pingpp?.charge && gon?.pingpp?.signature
    pingpp.createPayment(@getCharge(), @afterCreate, @getSignature(), false)
  afterCreate: (result, err) ->
    # console.log("#{result} #{err.msg} #{err.extra}")
    switch result
      when 'success'
        $('#successBtn').click()
      when 'fail'
        alert('failed')
      when 'cancel'
        # alert('cancel')
      else
        alert('unknown')
  getCharge: -> gon.pingpp.charge
  getSignature: -> gon.pingpp.signature

jQuery ->
  MessageBus.start()
  MessageBus.callbackInterval = 2000
