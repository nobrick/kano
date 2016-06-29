require_relative '../slack.rb'

module Slack
  module OrderNotifier
    def self.push_uncontracted_order(order)
      user_name = order.user.full_or_nickname
      slack.ping({"attachments": [
        {
          "pretext": "*#{user_name}* 有一个新的<#{url(order)}|未接订单>",
          "fallback": "#{user_name} 有一个未接订单 ##{order.id}",
          "color": "#7CD197",
          "fields": [
            {
              "title": 'ID',
              "value": "#{order.id}",
              "short": true
            },
            {
              "title": '项目',
              "value": "#{order.taxon_name}",
              "short": true
            },
            {
              "title": '用户',
              "value": "#{order.user.full_or_nickname}",
              "short": true
            },
            {
              "title": '用户电话',
              "value": "#{order.user.phone}",
              "short": true
            },
            {
              "title": '下单',
              "value": "#{order.created_at}",
              "short": true
            },
            {
              "title": '预约',
              "value": "#{order.arrives_at}",
              "short": true
            },
            {
              "title": '内容',
              "value": "#{order.content}",
              "short": false
            },
          ],
          "mrkdwn_in": ["pretext"]
        }
      ]})
    end

    def self.url(order)
      host = 'daxiangguanjia.com'
      helpers = Rails.application.routes.url_helpers
      helpers.admin_order_url(order, host: host, sc: 'user')
    end

    def self.slack
      @slack ||= Slack::Notifier.new(webhook_url)
    end

    def self.config
      Slack.config['orders']
    end

    def self.webhook_url
      config['webhook_url']
    end

    def self.channel
      config['channel']
    end
  end
end
