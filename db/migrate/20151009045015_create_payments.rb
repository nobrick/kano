class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :order, index: true, foreign_key: true, null: false
      t.string :payment_method, limit: 32, null: false
      t.decimal :total, null: false
      t.datetime :expires_at, null: false
      t.string :state, limit: 32, null: false
      t.inet :last_ip
      t.references :payment_profile, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_index :payments, :payment_method
    add_index :payments, :state
  end
end
