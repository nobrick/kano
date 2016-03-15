class AccountDashboard < BaseDashboard

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "name" => :string,
    "created_at" => :time,
    "email" => :string
  }

  SEARCH_PATH = "admin_user_accounts_path"

  SEARCH_PREDICATES = [:name_or_email_cont, :id_or_phone_eq]
end
