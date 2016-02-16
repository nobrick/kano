namespace :db do
  desc 'Initialize balance record base attributes'
  task :init_balance_record_base_attrs do |t, args|
    BalanceRecord.all.each do |r|
      unless r.base_adjustment && r.base_balance && r.previous_base_balance
        r.update_columns({
          base_adjustment: r.adjustment,
          base_balance: r.balance,
          previous_base_balance: r.previous_balance
        })
      end
    end
  end
end
