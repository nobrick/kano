class Withdrawal::VerificationDashboard < BaseDashboard
  RESOURCE_CLASS = "Withdrawal"

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "handyman.name" => :string,
    "handyman.id" => :string,
    "bank_code" => :i18n,
    "account_no" => :string,
    "total" => :string,
    "handyman.unfrozen_balance" => :string,
    "created_at" => :time,
    "_self_expand.verify_buttons" => nil
  }

  COLLECTION_FILTER = {
    "bank_code" => { type: :select, values: Withdrawal::Banking.invert_banks },
    "created_at" => { type: :time_range },
    "total" => { type: :range }
  }

  COLLECTION_FILTER_PATH_HELPER = "admin_finance_withdrawal_verifications_path"

  SEARCH_PREDICATES = [:handyman_name_cont, :id_or_handyman_id_eq]

  SEARCH_PATH_HELPER = "search_admin_finance_withdrawal_verifications_path"

  EXPAND_PARTIAL_PATH = "admin/finance/withdrawals/verifications"
end
