class User::OrderDashboard < AdminScaffold::BaseDashboard

  attributes("Order") do |d|
    d.string "id"
    d.date_time "created_at"
    d.string "state", i18n: true
    d.date_time "contracted_at"
    d.string "handyman.name", owner: "Handyman", methods: "handyman.name"
    d.string "handyman.id", owner: "Handyman", methods: "handyman.id"
    d.date_time "completed_at"
    d.date_time "canceled_at"
  end

  filters("admin_user_orders_path") do |f|
    f.time_range "created_at"
    f.time_range "contracted_at"
    f.eq "state", display: :select, values: Order.states
  end

  show_page "admin_order_path"
end
