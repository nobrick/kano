class RemovePaymentStateFromOrder < ActiveRecord::Migration
  def change
    remove_column :orders, :payment_state, :string
  end
end
