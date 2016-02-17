namespace :db do
  desc 'Initialize balance record withdrawal_total associated attributes'
  task :init_balance_record_withdrawal_total_associated_attrs do
    BalanceRecord.find_each do |r|
      unless r.withdrawal_total
        r.update_columns({
          withdrawal_total: 0,
          prev_withdrawal_total: 0,
          online_income_total: r.balance,
          prev_online_income_total: r.previous_balance
        })
      end
    end
  end
end
