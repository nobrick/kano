class OrderDashboard < BaseDashboard
  RESOURCE_CLASS = "Order"

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "created_at" => :time,
    "handyman.name" => :string,
    "user.name" => :string,
    "payment_total" => :string
  }
end
