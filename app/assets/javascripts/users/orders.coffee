@PageSels =
  orderNew: '.order-new-page'

@OrderNewPage =
  displayPriceField: ->
    city = $(@sel.citySelect).val()
    taxon = $(@sel.taxonSelect).val()
    hour = parseInt($(@sel.hourSelect).val())
    times = switch hour
      when 20, 21 then 1.2
      when 22, 23 then 1.5
      else 1
    if city != '' && taxon != '' && @pricing? && @pricing[city]?
      $(@sel.priceField).removeClass('hidden')
      $(@sel.nightLabel).toggleClass('hidden', times == 1)
      trafficPrice = @pricing[city]['_traffic']
      servicePrice = @pricing[city][taxon] * times
      totalPrice = trafficPrice + servicePrice
      $(@sel.trafficPrice).text(trafficPrice)
      $(@sel.servicePrice).text(servicePrice)
      $(@sel.totalPrice).text(totalPrice)
    else
      $(@sel.priceField).addClass('hidden')

  init: ->
    return unless $(PageSels.orderNew).length
    @pricing = $(@sel.priceField).data('pricing')
    @displayPriceField()
    $("#{@sel.citySelect}, #{@sel.taxonSelect}, #{@sel.hourSelect}").on 'change', =>
      @displayPriceField()

  sel:
    citySelect: "#{PageSels.orderNew} select.select-for-city"
    taxonSelect: "#{PageSels.orderNew} select#order_taxon_code"
    hourSelect: "#{PageSels.orderNew} .datetime-select.hour"
    priceField: "#{PageSels.orderNew} .price-desc-field"
    trafficPrice: "#{PageSels.orderNew} .traffic-price"
    servicePrice: "#{PageSels.orderNew} .service-price"
    totalPrice: "#{PageSels.orderNew} .total-price"
    nightLabel: "#{PageSels.orderNew} #night-desc-label"

jQuery ->
  OrderNewPage.init()
  $('#btn_start_payment').click ->
    PingppPayment.create()
