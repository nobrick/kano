class CreateBalanceRecords < ActiveRecord::Migration
  def change
    create_table :balance_records do |t|
      t.decimal :balance, null: false
      t.decimal :previous_balance, null: false
      t.decimal :cash_total, null: false
      t.decimal :previous_cash_total, null: false
      t.decimal :adjustment, null: false
      t.references :owner, polymorphic: true, null: false
      t.references :adjustment_event, polymorphic: true, null: false
      t.boolean :in_cash, default: false

      t.timestamps null: false
    end
    add_index :balance_records, :in_cash
    add_index :balance_records, [ :owner_id, :owner_type ],
      name: 'index_balance_records_on_owner'
    add_index :balance_records, [ :adjustment_event_id, :adjustment_event_type ],
      unique: true, name: 'index_balance_records_on_adjustment_event'
  end
end
