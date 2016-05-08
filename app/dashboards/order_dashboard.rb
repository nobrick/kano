class OrderDashboard < AdminScaffold::BaseDashboard

  attributes("Order") do |d|
    d.string "id"
    d.string "user.name", owner: "User", methods: "user.name"
    d.string "user.id", owner: "User", methods: "user.id"
    d.date_time "created_at"
    d.string "state", i18n: true
    d.string "handyman.name", owner: "Handyman", methods: "handyman.name"
    d.string "handyman.id", owner: "Handyman", methods: "handyman.id"
    d.date_time "contracted_at"
    d.date_time "completed_at"
    d.date_time "canceled_at"
  end

  filters("admin_orders_path") do |f|
    f.time_range "created_at"
    f.time_range "contracted_at"
    f.select "state", values: Order.states
    f.select "state", default_value: "requested", group: :link
    f.time_interval_gt "created_at", default_value: 15, group: :link
  end

  search("search_admin_orders_path") do |s|
    s.cont "handyman.name"
    s.eq   "handyman.id"
    s.eq   "id"
    s.eq   "user.id"
    s.cont "user.name"
  end

  show_page "admin_order_path"
end
