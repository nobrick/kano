module HandymanWechatApi
  module Templates
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def push_after_payment(payment)
        unless payment.handyman.on_wechat?
          raise 'Cannot send to non-wechat handyman'
        end
        wechat.template_message_send(payload_for(payment))
      end

      private

      def payload_for(payment)
        order = payment.order
        data = payload(order.payment_total,
                       order.taxon_name,
                       payment.in_cash?,
                       order.completed_at,
                       order.address.content)
        data = with_url(data, order)
        with_openid(data, payment.handyman)
      end

      def payload(amount, taxon_name, in_cash, paid_at, order_address)
        method = in_cash ? '现金' : '微信'
        {
          template_id: template_id,
          topcolor: "#FF0000",
          data: {
            first: {
              value: "用户已支付您的订单",
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
              value: order_address,
              color: "#777777"
            }
          }
        }
      end

      def template_id
        '980Jo2NdwbEkmbGG9yuh16uUXROc_PmSbbxIXUYO9c0'
      end

      def to_currency(number)
        ActiveSupport::NumberHelper.number_to_currency(number, unit: '￥')
      end

      def with_openid(payload, handyman)
        payload.merge(touser: handyman.uid)
      end

      def with_url(payload, order)
        helpers = Rails.application.routes.url_helpers
        url = helpers.handyman_order_url(order, host: 'daxiangguanjia.com')
        payload.merge(url: url)
      end
    end
  end
end
