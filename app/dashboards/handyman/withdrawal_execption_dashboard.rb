class Handyman::WithdrawalExecptionDashboard < AdminScaffold::BaseDashboard
  attributes("Withdrawal") do |d|
    d.string "id"
    d.string "bank_code", i18n: true
    d.string "account_no"
    d.number "total"
    d.string "handyman.phone", owner: "Handyman", mehtods: "handyman.phone"
    d.date_time "created_at"
  end

  show_page 'admin_handyman_finance_exception_path'
end
