class AccountDashboard < BaseDashboard

  ATTRIBUTE_TYPES = {
    "id" => :string,
    "name" => :string,
    "created_at" => :time,
    "email" => :string
  }
end
