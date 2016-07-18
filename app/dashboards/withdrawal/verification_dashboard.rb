class Withdrawal::VerificationDashboard < AdminScaffold::BaseDashboard

  attributes("Withdrawal") do |d|
    d.string "id"
    d.string "handyman.name", owner: 'Handyman', methods: "handyman.name"
    d.string "handyman.id", owner: 'Handyman', methods: "handyman.id"
    d.string "bank_code", i18n: true
    d.string "account_no"
    d.number "total"
    d.date_time "created_at"
    d.expand "verify_buttons", partial_path: "admin/finance/withdrawals/verifications", table_header: false
  end

  filters("admin_finance_withdrawal_verifications_path") do |f|
    f.eq "bank_code", display: :select, values: Withdrawal::Banking.bank_codes
    f.time_range "created_at"
    f.range "total"
  end

  search("search_admin_finance_withdrawal_verifications_path") do |s|
    s.cont "handyman.name"
    s.eq   "id"
    s.eq   "handyman.id"
  end

  show_page "admin_finance_withdrawal_path"
end
