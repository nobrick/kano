class AccountDashboard < AdminScaffold::BaseDashboard

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "name" => :string,
    "nickname" => :string,
    "phone" => :string,
    "email" => :string,
    "created_at" => :time,
    "last_sign_in_at" => :time
  }

end
