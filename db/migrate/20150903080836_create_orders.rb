class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :user, index: true, null: false
      t.references :handyman, index: true
      t.string :taxon_code, limit: 30, null: false
      t.string :content, null: false
      t.datetime :arrives_at, null: false
      t.datetime :established_at
      t.datetime :completed_at
      t.decimal :user_total
      t.decimal :payment_total
      t.decimal :user_promo_total
      t.decimal :handyman_bonus_total
      t.decimal :handyman_total
      t.references :transferee_order, index: true
      t.string :transfer_type, limit: 30
      t.string :transfer_reason
      t.datetime :transferred_at
      t.references :transferor, index: true
      t.string :cancel_type, limit: 30
      t.string :cancel_reason
      t.datetime :canceled_at
      t.references :canceler, index: true
      t.integer :rating
      t.string :rating_content
      t.datetime :rated_at
      t.string :report_type, limit: 30
      t.string :report_content
      t.datetime :reported_at
      t.string :state, null: false, default: 'requested'
      t.string :payment_state, null: false, default: 'initial'

      t.timestamps null: false
    end
    add_index :orders, :taxon_code
    add_index :orders, :arrives_at
    add_index :orders, :established_at
    add_index :orders, :completed_at
    add_index :orders, :user_total
    add_index :orders, :payment_total
    add_index :orders, :user_promo_total
    add_index :orders, :handyman_bonus_total
    add_index :orders, :handyman_total
    add_index :orders, :transfer_type
    add_index :orders, :transferred_at
    add_index :orders, :cancel_type
    add_index :orders, :canceled_at
    add_index :orders, :rating
    add_index :orders, :rated_at
    add_index :orders, :report_type
    add_index :orders, :reported_at
    add_index :orders, :state
    add_index :orders, :payment_state
    add_foreign_key :orders, :accounts, column: :user_id
    add_foreign_key :orders, :accounts, column: :handyman_id
    add_foreign_key :orders, :accounts, column: :transferor_id
    add_foreign_key :orders, :accounts, column: :canceler_id
  end
end
