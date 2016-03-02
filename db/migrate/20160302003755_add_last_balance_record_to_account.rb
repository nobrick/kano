class AddLastBalanceRecordToAccount < ActiveRecord::Migration
  def change
    add_reference :accounts, :last_balance_record, index: true
    add_foreign_key :accounts, :balance_records, column: :last_balance_record_id
    Rake::Task['db:init_account_last_balance_record'].invoke
  end
end
