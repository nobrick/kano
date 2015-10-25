#= require jquery
#= require jquery_ujs
#= require china_city/jquery.china_city
#= require turbolinks
#= require bootstrap
#= require message-bus
#= require_tree .
MessageBus.start()
MessageBus.callbackInterval = 5000
MessageBus.subscribe "/channel/#{gon.account_access_token}", (json) ->
  console.log(json)
