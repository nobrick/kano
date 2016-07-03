module Users::OrdersHelper
  def cache_key_for_show_page(order, version)
    [
      version,
      order,
      order.arrives_at_expired?,
      wechat_request_or_debug?,
      handyman_avatar_basename(order)
    ]
  end

  def cache_key_for_index_page(orders, version)
    time = Time.now
    [
      version,
      orders,
      orders.map { |o| o.arrives_at_valid?(time) },
      orders.map { |o| handyman_avatar_basename(o) }.compact,
    ]
  end

  private

  def handyman_avatar_basename(order)
    order.try(:handyman).try(:avatar).try(:file).try(:basename)
  end
end
