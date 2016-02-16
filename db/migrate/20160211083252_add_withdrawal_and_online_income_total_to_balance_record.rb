class AddWithdrawalAndOnlineIncomeTotalToBalanceRecord < ActiveRecord::Migration
  def up
    add_column :balance_records, :withdrawal_total, :decimal, precision: 12, scale: 2
    add_column :balance_records, :prev_withdrawal_total, :decimal, precision: 12, scale: 2
    add_column :balance_records, :online_income_total, :decimal, precision: 12, scale: 2
    add_column :balance_records, :prev_online_income_total, :decimal, precision: 12, scale: 2
    Rake::Task['db:init_balance_record_withdrawal_total_associated_attrs'].invoke
    change_column_null :balance_records, :withdrawal_total, false
    change_column_null :balance_records, :prev_withdrawal_total, false
    change_column_null :balance_records, :online_income_total, false
    change_column_null :balance_records, :prev_online_income_total, false
  end

  def down
    remove_column :balance_records, :withdrawal_total
    remove_column :balance_records, :prev_withdrawal_total
    remove_column :balance_records, :online_income_total
    remove_column :balance_records, :prev_online_income_total
  end
end
