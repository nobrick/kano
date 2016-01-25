class OrderDashboard < BaseDashboard
  RESOURCE_CLASS = "Order"


  ATTRIBUTE_TYPES = {
    "created_at" => :time,
    "handyman.name" => :string,
    "user.name" => :string,
    "payment_total" => :string
  }


  PATH_HELPER = nil
end
