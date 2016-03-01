class AccountDashboard < BaseDashboard

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "name" => :string,
    "created_at" => :time,
    "email" => :string
  }
end
