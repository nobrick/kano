class Handyman::OrderDashboard < AdminScaffold::BaseDashboard

  attributes("Order") do |d|
    d.string "id"
    d.date_time "created_at"
    d.string "state", i18n: true
    d.date_time "contracted_at"
    d.string "user.full_or_nickname", owner: "User", methods: "user.full_or_nickname"
    d.string "user.id", owner: "User", methods: "user.id"
    d.date_time "completed_at"
    d.date_time "canceled_at"
  end

  filters("admin_handyman_orders_path") do |f|
    f.time_range "created_at"
    f.time_range "contracted_at"
    f.eq "state", display: :select, values: Order.states
  end

  show_page "admin_order_path"
end
