class Withdrawal::TransferDashboard < AdminScaffold::BaseDashboard

  attributes("Withdrawal") do |d|
    d.string "id"
    d.string "handyman.name", owner: "Handyman", methods: "handyman.name"
    d.string "handyman.id", owner: "Handyman", methods: "handyman.id"
    d.string "bank_code", i18n: true
    d.string "account_no"
    d.number "total"
    d.string "handyman.phone", owner: 'Handyman', methods: "handyman.phone"
    d.date_time "created_at"
    d.expand "transfer_buttons", partial_path: "admin/finance/withdrawals/transfer", table_header: false
  end

  filters("admin_finance_withdrawal_transfer_index_path") do |f|
    f.eq "bank_code",display: :select ,values: Withdrawal::Banking.bank_codes
    f.time_range "created_at"
    f.range "total"
  end

  search("search_admin_finance_withdrawal_transfer_index_path") do |s|
    s.cont "handyman.name"
    s.eq   "id"
    s.eq   "handyman.id"
  end

  show_page "admin_finance_withdrawal_path"

  excel_export
end
