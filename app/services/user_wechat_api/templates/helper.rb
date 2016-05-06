module UserWechatApi
  module Templates
    module Helper
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
