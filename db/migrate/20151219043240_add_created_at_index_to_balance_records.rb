class AddCreatedAtIndexToBalanceRecords < ActiveRecord::Migration
  def up
    add_index :balance_records, :created_at
  end

  def down
    remove_index :balance_records, :created_at
  end
end
