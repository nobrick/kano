class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
      t.references :handyman, index: true, null: false
      t.references :unfrozen_record, null: false
      t.decimal :total, precision: 12, scale: 2, null: false
      t.string :bank_code, limit: 16, null: false
      t.string :account_no, limit: 32, null: false
      t.string :state, limit: 16, null: false
      t.references :authorizer, index: true
      t.string :reason_message
      t.datetime :transferred_at
      t.datetime :declined_at

      t.timestamps null: false
    end
    add_index :withdrawals, :account_no
    add_index :withdrawals, :state
    add_index :withdrawals, :transferred_at
    add_index :withdrawals, :declined_at
    add_index :withdrawals, :created_at
    add_foreign_key :withdrawals, :accounts, column: :handyman_id
    add_foreign_key :withdrawals, :accounts, column: :authorizer_id
    add_foreign_key :withdrawals, :balance_records, column: :unfrozen_record_id
  end
end
