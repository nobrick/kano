module UserWechatApi
  module Templates
    module AfterContract
      extend ::UserWechatApi::Templates::Helper

      def push_after_contract(order)
        raise 'Cannot send to non-wechat user' unless order.user.on_wechat?
        wechat.template_message_send(AfterContract.payload_for(order))
      end

      private

      def self.payload_for(order)
        data = payload(order.id,
                       order.taxon_name,
                       order.handyman.full_or_nickname,
                       order.contracted_at)
        data = with_url(data, order)
        with_openid(data, order.user)
      end

      def self.payload(id, taxon_name, handyman_name, contracted_at)
        {
          template_id: template_id,
          topcolor: "#FF0000",
          data: {
            first: {
              value: '您的订单已成功接单',
              color: '#0A0A0A'
            },
            keyword1: {
              value: id,
              color: '#173177'
            },
            keyword2: {
              value: taxon_name,
              color: '#173177'
            },
            keyword3: {
              value: handyman_name,
              color: '#173177'
            },
            keyword4: {
              value: I18n.localize(contracted_at),
              color: '#173177'
            },
            remark: {
              value: '稍后师傅将与您联系，请保持电话畅通。',
              color: '#777777'
            }
          }
        }
      end

      def self.template_id
        'y8dwmQzAv1wAbqvvTHZmno3B5dyuqt7xmTcJ7fV00Hw'
      end
    end
  end
end
