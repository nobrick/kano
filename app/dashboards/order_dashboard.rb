class OrderDashboard < AdminScaffold::BaseDashboard

  attributes("Order") do |d|
    d.string "id"
    d.string "taxon_code", methods: "taxon_name"
    d.string "user.full_or_nickname", owner: "User", methods: "user.full_or_nickname"
    d.date_time "created_at"
    d.date_time "arrives_at"
    d.string "state", i18n: true
    d.string "handyman.name", owner: "Handyman", methods: "handyman.name"
    d.date_time "completed_at"
  end

  filters("admin_orders_path") do |f|
    f.time_range "created_at"
    f.time_range "arrives_at"
    f.eq "state", display: :select, values: Order.states
    f.filter_group("order_for_notify", name: "未及时接单", type: :link) do |g|
      g.eq "state", default_value: "requested"
      g.time_interval_gt "created_at", default_value: 15
    end
  end

  search("search_admin_orders_path") do |s|
    s.eq "id"

    # FIXME: There is no need to ensure the searching attributes are defined in
    # the `attributes("Order")` fields, since the latter is only used for
    # visually displaying explicit columns in the table of the index page.
    # Therefore we should allow the attributes not explicitly demonstrated in
    # the model attribute fields for searching purposes.

    # s.eq "user.phone"
    # s.eq "handyman.phone"
  end

  show_page "admin_order_path"
end
