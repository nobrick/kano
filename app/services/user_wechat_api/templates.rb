module UserWechatApi
  module Templates
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def push_after_payment(payment)
        raise 'Cannot send to non-wechat user' unless payment.user.on_wechat?
        wechat.template_message_send(payload_for(payment))
      end

      private

      def payload_for(payment)
        order = payment.order
        data = payload(order.payment_total,
                       order.taxon_name,
                       payment.in_cash?,
                       order.completed_at)
        data = with_url(data, order)
        with_openid(data, payment.user)
      end

      def payload(amount, taxon_name, in_cash, paid_at)
        method = in_cash ? '现金' : '微信'
        {
          template_id: template_id,
          topcolor: "#FF0000",
          data: {
            first: {
              value: "您的订单已支付",
              color: "#0A0A0A"
            },
            keyword1: {
              value: to_currency(amount),
              color: "#173177"
            },
            keyword2: {
              value: "#{method}支付",
              color: "#173177"
            },
            keyword3: {
              value: taxon_name,
              color: "#173177"
            },
            keyword4: {
              value: I18n.localize(paid_at),
              color: "#173177"
            },
            remark: {
              value: "大象管家，用心呵护您的家。欢迎您再次使用。",
              color: "#777777"
            }
          }
        }
      end

      def template_id
        'tIPBXlG-PaiPHzyolBRBs8I5yLbTTSNhZr7CE4KcyE0'
      end

      def to_currency(number)
        ActiveSupport::NumberHelper.number_to_currency(number, unit: '￥')
      end

      def with_openid(payload, user)
        payload.merge(touser: user.uid)
      end

      def with_url(payload, order)
        helpers = Rails.application.routes.url_helpers
        url = helpers.user_order_url(order, host: 'daxiangguanjia.com')
        payload.merge(url: url)
      end
    end
  end
end
