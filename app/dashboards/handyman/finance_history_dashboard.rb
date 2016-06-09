class Handyman::FinanceHistoryDashboard < AdminScaffold::BaseDashboard
  attributes("BalanceRecord") do |d|
    d.string "adjustment_event_type", i18n: true
    d.date_time "created_at"
    d.string "id"
    d.number "adjustment"
    d.string "adjustment_event.payment_method", i18n: true, owner: 'Payment', methods: "adjustment_event.payment_method"
    d.number "balance"
    d.number "withdrawal_total"
    d.number "bonus_sum_total"
    d.number "online_income_total"
    d.number "cash_total"
    d.expand "withdrawal_history", partial_path: "admin/handymen/finance/history"
  end

  filters("admin_handyman_finance_history_index_path") do |f|
    f.eq "adjustment_event_type", display: :select, values: ["Withdrawal", "Payment"]
    f.time_range "created_at"
    f.range "withdrawal_total"
  end
end
