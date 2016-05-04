class UserWechatsController < ApplicationController
  skip_before_action :verify_authenticity_token
  wechat_responder

  on :event, with: 'subscribe' do |request|
    request.reply.text '欢迎您关注大象管家'
  end
end
