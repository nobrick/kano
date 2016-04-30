class Withdrawal::ExceptionDashboard < AdminScaffold::BaseDashboard

  attributes("Withdrawal") do |d|
    d.string "id"
    d.string "handyman.name", owner: 'Handyman', methods: "handyman.name"
    d.string "handyman.id", owner: "Handyman", methods: "handyman.id"
    d.string "bank_code", i18n: true
    d.string "account_no"
    d.number "total"
    d.string "handyman.phone", owner: "Handyman", mehtods: "handyman.phone"
    d.date_time "created_at"
  end

  search("search_admin_finance_withdrawal_exceptions_path") do |s|
    s.cont "handyman.name"
    s.eq   "id"
    s.eq   "handyman.id"
  end
end
