class AlterColumnsInBalanceRecord < ActiveRecord::Migration
  def change
    add_column :balance_records, :bonus_sum_total, :decimal, precision: 12, scale: 2
    add_column :balance_records, :prev_bonus_sum_total, :decimal, precision: 12, scale: 2
    Rake::Task['db:init_balance_record_bonus_sum_total'].invoke
    change_column_null :balance_records, :bonus_sum_total, false
    change_column_null :balance_records, :prev_bonus_sum_total, false

    remove_column :balance_records, :base_balance
    remove_column :balance_records, :prev_base_balance
    remove_column :balance_records, :base_adjustment
  end
end
