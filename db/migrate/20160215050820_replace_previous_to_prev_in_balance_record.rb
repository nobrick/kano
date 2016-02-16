class ReplacePreviousToPrevInBalanceRecord < ActiveRecord::Migration
  def change
    rename_column :balance_records, :previous_balance, :prev_balance
    rename_column :balance_records, :previous_cash_total, :prev_cash_total
    rename_column :balance_records, :previous_base_balance, :prev_base_balance
  end
end
