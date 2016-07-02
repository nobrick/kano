module Users::OrdersHelper
  def cache_key_for_show_page(order, version)
    [
      version,
      order,
      order.arrives_at_expired?,
      wechat_request_or_debug?,
      order.try(:handyman).try(:avatar).try(:file).try(:basename)
    ]
  end
end
