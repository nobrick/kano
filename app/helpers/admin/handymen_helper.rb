module Admin::HandymenHelper
  def admin_handyman_render_tabs
    tabs_info = [
      {
        text: "技能认证管理",
        path: admin_handyman_certifications_path
      },
      {
        text: "师傅信息管理",
        path: admin_handyman_index_path
      }
    ]
    admin_render_tabs(tabs_info)
  end

  def admin_handyman_finance_render_tabs(handyman)
    tabs_info = [
      {
        text: "财务历史",
        path: admin_handyman_finance_history_index_path(handyman)
      },
      {
        text: "异常提现",
        path: admin_handyman_finance_exceptions_path(handyman)
      }
    ]
    admin_render_tabs(tabs_info)
  end

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
    return 0 if handyman.orders.finished.count == 0
    (handyman.balance / handyman.orders.finished.count).round(3)
  end
end
