class Withdrawal::HistoryDashboard < AdminScaffold::BaseDashboard

  attributes("Withdrawal") do |d|
    d.string "id"
    d.string "handyman.name", owner: 'Handyman', methods: "handyman.name"
    d.string "handyman.id", owner: 'Handyman', methods: "handyman.id"
    d.string "bank_code", i18n: true
    d.string "account_no"
    d.number "total"
    d.string "handyman.phone", owner: 'Handyman', methods: "handyman.phone"
    d.date_time "created_at"
    d.string "state", i18n: true
    d.date_time "declined_at_or_transferred_at"
  end

  filters("admin_finance_withdrawal_history_index_path") do |f|
    f.select "bank_code", values: Withdrawal::Banking.bank_codes
    f.time_range "created_at"
    f.time_range "declined_at_or_transferred_at"
    f.radio "state", values: [ "declined", "transferred" ]
    f.range "total"
  end

  search("search_admin_finance_withdrawal_history_index_path") do |s|
    s.cont "handyman.name"
    s.eq   "id"
    s.eq   "handyman.id"
  end

  excel_export
end
