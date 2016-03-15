class Withdrawal::VerificationDashboard < BaseDashboard
  RESOURCE_CLASS = "Withdrawal"

  COLLECTION_ATTRIBUTES = {
    "id" => :string,
    "handyman.name" => :string,
    "handyman.id" => :string,
    "bank_code" => :i18n,
    "account_no" => :string,
    "total" => :string,
    "handyman.balance" => :string,
    "created_at" => :time,
    "_self_expand.verify_buttons" => nil
  }

  EXPAND_PARTIAL_PATH = "admin/finance/withdrawals/verifications"
end
