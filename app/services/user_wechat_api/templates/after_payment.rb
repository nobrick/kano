module UserWechatApi
  module Templates
    module AfterPayment
      extend ::UserWechatApi::Templates::Helper

      def push_after_payment(payment)
        raise 'Cannot send to non-wechat user' unless payment.user.on_wechat?
        wechat.template_message_send(AfterPayment.payload_for(payment))
      end

      private

      def self.payload_for(payment)
        order = payment.order
        data = payload(order.payment_total,
                       order.taxon_name,
                       payment.in_cash?,
                       order.completed_at)
        data = with_url(data, order)
        with_openid(data, payment.user)
      end

      def self.payload(amount, taxon_name, in_cash, paid_at)
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

      def self.template_id
        'tIPBXlG-PaiPHzyolBRBs8I5yLbTTSNhZr7CE4KcyE0'
      end
    end
  end
end
