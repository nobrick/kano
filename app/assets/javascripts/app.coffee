#= require ./users/orders

@Global =
  debug: false
  getDebugInfo: ->
    """
    ORDER: #{gon.order_id}
    CHARGE: #{gon?.pingpp_charge}
    WX_CFG: #{gon?.wechat}
    APPID: #{gon.wechat.appid}
    STAMP: #{gon.wechat.timestamp}
    NONCE: #{gon.wechat.noncestr}
    SIG: #{gon.wechat.signature}
    URL: #{location.href.split('#')[0]}
    """

@alertOnDebug = (message) ->
  alert(message) if Global.debug

@PingppPayment =
  create: ->
    alertOnDebug Global.getDebugInfo()
    PingppCharge.fetch (charge) ->
      alertOnDebug("charge after fetch: #{charge}")
      if charge?
        pingpp.createPayment(charge, PingppPayment.afterCreate, gon.wechat.signature, Global.debug)
      else
        $('#btn_check_payment_problem').click()

  afterCreate: (result, err) ->
    alertOnDebug "RESULT: #{result} MSG: #{err.msg} EXTRA: #{err.extra} GLOBAL:\n#{Global.getDebugInfo()}"
    switch result
      when 'success' then $('#btn_check_payment_problem').click()
      when 'fail' then alert("支付失败。原因：#{err.msg} #{err.extra}")

@PingppCharge =
  fetch: (success) ->
    @fetchRemote(success)

  fetchRemote: (success) ->
    $.ajax
      type: 'GET'
      url: "#{gon.order_id}/charge"
    .done (data) ->
      gon.pingpp_charge = data
      alertOnDebug("charged fetched: #{data}")
      success(data)
    .fail (xhr, textStatus) ->
      alertOnDebug("Request failed: #{textStatus}")

jQuery ->
  if gon.wechat?.appid
    wx.config
      debug: Global.debug
      appId: gon.wechat.appid
      timestamp: gon.wechat.timestamp
      nonceStr: gon.wechat.noncestr
      signature: gon.wechat.signature
      jsApiList: ['chooseWXPay']
    wx.ready ->
      alertOnDebug('WX_READY')
    wx.error (res) ->
      alertOnDebug("ERR.\n#{Global.getDebugInfo()}")
