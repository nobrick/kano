class SetPrecisionAndScaleForDecimalColumns < ActiveRecord::Migration
  def change
    change_column :orders,          :user_total,           :decimal, precision: 12, scale: 2
    change_column :orders,          :payment_total,        :decimal, precision: 12, scale: 2
    change_column :orders,          :user_promo_total,     :decimal, precision: 12, scale: 2
    change_column :orders,          :handyman_bonus_total, :decimal, precision: 12, scale: 2
    change_column :orders,          :handyman_total,       :decimal, precision: 12, scale: 2
    change_column :balance_records, :balance,              :decimal, precision: 12, scale: 2
    change_column :balance_records, :previous_balance,     :decimal, precision: 12, scale: 2
    change_column :balance_records, :cash_total,           :decimal, precision: 12, scale: 2
    change_column :balance_records, :previous_cash_total,  :decimal, precision: 12, scale: 2
    change_column :balance_records, :adjustment,           :decimal, precision: 12, scale: 2
  end
end
