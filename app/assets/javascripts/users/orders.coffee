@OrderNewPage =
  displayPriceField: ->
    city = $(@sel.citySelect).val()
    taxon = $(@sel.taxonSelect).val()
    if city != '' && taxon != '' && @pricing? && @pricing[city]?
      $(@sel.priceField).removeClass('hidden')
      trafficPrice = @pricing[city]['_traffic']
      servicePrice = @pricing[city][taxon]
      totalPrice = trafficPrice + servicePrice
      $(@sel.trafficPrice).text(trafficPrice)
      $(@sel.servicePrice).text(servicePrice)
      $(@sel.totalPrice).text(totalPrice)
    else
      $(@sel.priceField).addClass('hidden')

  hookSelectElements: ->
    @pricing = $(@sel.priceField).data('pricing')
    @displayPriceField()
    $("#{@sel.citySelect}, #{@sel.taxonSelect}").on 'change', => @displayPriceField()

  sel:
    citySelect: '.order-new-page select.select-for-city'
    taxonSelect: '.order-new-page select#order_taxon_code'
    priceField: '.order-new-page .price-desc-field'
    trafficPrice: '.order-new-page .traffic-price'
    servicePrice: '.order-new-page .service-price'
    totalPrice: '.order-new-page .total-price'

jQuery ->
  OrderNewPage.hookSelectElements()
  $('#btn_start_payment').click ->
    PingppPayment.create()
