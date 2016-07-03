Sels =
  orderNew: '.order-new-page'
  orderContracted: '.order-contracted-view'

Pricing =
  calc: (trafficPrice, baseServicePrice, hour) ->
    times = switch hour
      when 20, 21 then 1.2
      when 22, 23 then 1.5
      else 1
    servicePrice = baseServicePrice * times
    {
      times: times
      nightMode: times > 1
      trafficPrice: trafficPrice
      baseServicePrice: baseServicePrice
      servicePrice: servicePrice
      totalPrice: trafficPrice + servicePrice
    }
  applyWith: (pricing, sels) ->
    $(sels.nightLabel).toggleClass('hidden', !pricing.nightMode)
    $(sels.trafficPrice).text(pricing.trafficPrice)
    $(sels.servicePrice).text(pricing.servicePrice)
    $(sels.totalPrice).text(pricing.totalPrice)

  calcAndApply: (trafficPrice, baseServicePrice, hour, sels) ->
    pricing = @calc(trafficPrice, baseServicePrice, hour)
    @applyWith(pricing, sels)
    pricing


@OrderContractedView =
  init: ->
    return unless $(Sels.orderContracted).length
    @displayPriceField()

  displayPriceField: ->
    priceField = $(@sels.priceField)
    trafficPrice = parseInt(priceField.data('traffic-price'))
    taxonPrice = parseInt(priceField.data('taxon-price'))
    hour = parseInt(priceField.data('hour-arrives-at'))
    Pricing.calcAndApply(trafficPrice, taxonPrice, hour, @sels)

  sels:
    priceField: "#{Sels.orderContracted} .price-desc-field"
    trafficPrice: "#{Sels.orderContracted} .traffic-price"
    servicePrice: "#{Sels.orderContracted} .service-price"
    totalPrice: "#{Sels.orderContracted} .total-price"
    nightLabel: "#{Sels.orderContracted} .night-desc-label"

@OrderNewPage =
  init: ->
    return unless $(Sels.orderNew).length
    @pricing = $(@sels.priceField).data('pricing')
    @displayPriceField()
    $("#{@sels.citySelect}, #{@sels.taxonSelect}, #{@sels.hourSelect}").on 'change', =>
      @displayPriceField()

    $(@sels.vcodePushBtn).on 'click', (e) =>
      e.preventDefault()
      phone = $(@sels.phoneField).val().trim()
      @push_vcode(phone)

    $(@sels.phoneField).on 'input', (e) =>
      userPhone = $(@sels.phoneField).data('phone').toString()
      if $(@sels.phoneField).val() == userPhone
        $(@sels.smsZone).addClass('hidden')
      else
        $(@sels.smsZone).removeClass('hidden')

  push_vcode: (phone) ->
    unless phone?.match(/^1\d{10}$/)
      alert('手机号码无效')
      return

    $(@sels.vcodePushBtn).html('发送中')
    $(@sels.vcodePushBtn).prop('disabled', true)

    enableVcode = =>
      $(@sels.vcodePushBtn).prop('disabled', false)
      $(@sels.vcodePushBtn).html('重发短信')

    $.ajax
      type: 'POST'
      url: '/phone_verifications'
      data: { phone: phone }
    .done (data) =>
      switch data.code
        when 0
          flash = OrderNewPage.flashVcodePushBtn
          OrderNewPage.vcodeBtnInterv = setInterval(flash, 1000)
          return
        when -1 then switch data.msg
          when 'TOO_MANY_REQUESTS'
            alert('暂时无法发送短信，请您稍后重试')
          else
            alert("发送失败：#{data.msg}")
        else
          alert("发送失败（#{data.code}）：#{data.msg}")
      enableVcode()
    .fail (xhr, textStatus) ->
      textStatus = '未知错误' if textStatus == 'error'
      alert("发送失败: #{textStatus}")
      enableVcode()

  flashVcodePushBtn: ->
    @sels ||= OrderNewPage.sels
    @timeToEnable ||= 60
    @timeToEnable -= 1
    if @timeToEnable > 0
      $(@sels.vcodePushBtn).html("#{@timeToEnable}秒后重发")
    else
      clearInterval(OrderNewPage.vcodeBtnInterv)
      @timeToEnable = null
      $(@sels.vcodePushBtn).html('重发短信')
      $(@sels.vcodePushBtn).prop('disabled', false)

  displayPriceField: ->
    city = $(@sels.citySelect).val()
    taxon = $(@sels.taxonSelect).val()
    hour = parseInt($(@sels.hourSelect).val())
    if city != '' && taxon != '' && @pricing? && @pricing[city]?
      $(@sels.priceField).removeClass('hidden')
      Pricing.calcAndApply(@pricing[city]['_traffic'], @pricing[city][taxon], hour, @sels)
    else
      $(@sels.priceField).addClass('hidden')

  sels:
    citySelect: "#{Sels.orderNew} select.select-for-city"
    taxonSelect: "#{Sels.orderNew} select#order_taxon_code"
    hourSelect: "#{Sels.orderNew} .datetime-select.hour"
    priceField: "#{Sels.orderNew} .price-desc-field"
    trafficPrice: "#{Sels.orderNew} .traffic-price"
    servicePrice: "#{Sels.orderNew} .service-price"
    totalPrice: "#{Sels.orderNew} .total-price"
    nightLabel: "#{Sels.orderNew} .night-desc-label"
    vcodePushBtn: "#{Sels.orderNew} .btn-request-user-vcode"
    phoneField: "#{Sels.orderNew} input#phone"
    smsZone: "#{Sels.orderNew} .sms-zone"

jQuery ->
  OrderNewPage.init()
  OrderContractedView.init()
  $('#btn_start_payment').click ->
    PingppPayment.create()
