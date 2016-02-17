namespace :db do
  desc 'Initialize balance record bonus total attributes'
  task :init_balance_record_bonus_sum_total do
    BalanceRecord.find_each do |r|
      unless r.bonus_sum_total
        r.update_columns({
          bonus_sum_total: r.balance - r.base_balance,
          prev_bonus_sum_total: r.prev_balance - r.prev_base_balance
        })
      end
    end
  end
end
