module Admin::Handymen::AccountsHelper
  def finished_rate(handyman)
    orders_total = handyman.orders.count
    return "0%" if orders_total == 0
    finished_orders_total = handyman.orders.finished.count
    "#{ (Float(finished_orders_total) / orders_total * 100).round(3) }%"
  end

  def finished_orders_count_per_day(handyman)
    time_interval = Date.current - handyman.created_at.to_date
    return 0 if time_interval == 0
    (Float(handyman.orders.count) / time_interval).round(3)
  end

  def profit_per_order(handyman)
    return 0 if handyman.orders.count == 0
    (handyman.balance / handyman.orders.finished.count).round(3)
  end
end
