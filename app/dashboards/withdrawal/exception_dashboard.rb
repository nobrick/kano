class Withdrawal::ExceptionDashboard < AdminScaffold::BaseDashboard
  RESOURCE_CLASS = "Withdrawal"

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "handyman.name" => :string,
    "handyman.id" => :string,
    "bank_code" => :i18n,
    "account_no" => :string,
    "total" => :string,
    "handyman.phone" => :string,
    "created_at" => :time,
  }

  SEARCH_PREDICATES = [:handyman_name_cont, :id_or_handyman_id_eq]

  SEARCH_PATH_HELPER = "search_admin_finance_withdrawal_exceptions_path"
end
