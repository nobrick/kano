class OrderDashboard < BaseDashboard
  RESOURCE_CLASS = "Order"

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "user.name" => :string,
    "user.id" => :string,
    "created_at" => :time,
    "state" => :i18n,
    "handyman.name" => :string,
    "handyman.id" => :string,
    "contracted_at" => :time,
    "arrives_at" => :time,
    "completed_at" => :time,
    "canceled_at" => :time,
    "payment_total" => :string
  }

  SEARCH_PATH_HELPER = "search_admin_orders_path"

  SEARCH_PREDICATES = [:handyman_name_cont, :handyman_id_eq, :id_eq, :user_id_eq, :user_name_cont]

  SHOW_PATH_HELPER = "admin_order_path"

  COLLECTION_FILTER = {
    "created_at" => { type: :time_range },
    "contracted_at" => { type: :time_range },
    "state" => { type: :select, values: Order.states }
  }

  COLLECTION_FILTER_PATH_HELPER = "admin_orders_path"
end
