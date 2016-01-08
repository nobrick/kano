@Sels =
  orderNew: '.order-new-page'
  orderContracted: '.order-contracted-view'

@Pricing =
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
  displayPriceField: ->
    city = $(@sels.citySelect).val()
    taxon = $(@sels.taxonSelect).val()
    hour = parseInt($(@sels.hourSelect).val())
    if city != '' && taxon != '' && @pricing? && @pricing[city]?
      $(@sels.priceField).removeClass('hidden')
      Pricing.calcAndApply(@pricing[city]['_traffic'], @pricing[city][taxon], hour, @sels)
    else
      $(@sels.priceField).addClass('hidden')

  init: ->
    return unless $(Sels.orderNew).length
    @pricing = $(@sels.priceField).data('pricing')
    @displayPriceField()
    $("#{@sels.citySelect}, #{@sels.taxonSelect}, #{@sels.hourSelect}").on 'change', =>
      @displayPriceField()

  sels:
    citySelect: "#{Sels.orderNew} select.select-for-city"
    taxonSelect: "#{Sels.orderNew} select#order_taxon_code"
    hourSelect: "#{Sels.orderNew} .datetime-select.hour"
    priceField: "#{Sels.orderNew} .price-desc-field"
    trafficPrice: "#{Sels.orderNew} .traffic-price"
    servicePrice: "#{Sels.orderNew} .service-price"
    totalPrice: "#{Sels.orderNew} .total-price"
    nightLabel: "#{Sels.orderNew} .night-desc-label"

jQuery ->
  OrderNewPage.init()
  OrderContractedView.init()
  $('#btn_start_payment').click ->
    PingppPayment.create()
