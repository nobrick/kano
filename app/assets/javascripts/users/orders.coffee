jQuery ->
  $('#repayBtn').click ->
    PingppPayment.create()
  channel = "/channel/#{gon.account_access_token}/charge"
  MessageBus.subscribe channel, (charge) ->
    gon.pingpp.charge = charge
    PingppPayment.create()
