class AddBaseAttributesToBalanceRecord < ActiveRecord::Migration
  def up
    add_column :balance_records, :base_adjustment, :decimal,
      precision: 12, scale: 2
    add_column :balance_records, :base_balance, :decimal,
      precision: 12, scale: 2
    add_column :balance_records, :previous_base_balance, :decimal,
      precision: 12, scale: 2
    Rake::Task['db:init_balance_record_base_attrs'].invoke
    change_column_null :balance_records, :base_adjustment, false
    change_column_null :balance_records, :base_balance, false
    change_column_null :balance_records, :previous_base_balance, false
  end

  def down
    remove_column :balance_records, :base_adjustment
    remove_column :balance_records, :base_balance
    remove_column :balance_records, :previous_base_balance
  end
end
