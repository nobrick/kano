class Withdrawal::HistoryDashboard < BaseDashboard
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
    "state" => :i18n,
    "transferred_or_declined_at" => :time,
  }

  COLLECTION_FILTER = {
    "bank_code" => { type: :select, values: Withdrawal::Banking.invert_banks },
    "created_at" => { type: :time_range },
    "transferred_or_declined_at" => { type: :time_range },
    "state" => { type: :radio, values: { I18n.t("withdrawal.state.declined") => "declined", I18n.t("withdrawal.state.transferred") => "transferred"} },
    "total" => { type: :range }
  }

  COLLECTION_FILTER_PATH_HELPER = "admin_finance_withdrawal_history_index_path"

  SEARCH_PREDICATES = [:handyman_name_cont, :id_or_handyman_id_eq]

  SEARCH_PATH_HELPER = "search_admin_finance_withdrawal_history_index_path"

  EXPAND_PARTIAL_PATH = "admin/finance/withdrawals/history"
end
