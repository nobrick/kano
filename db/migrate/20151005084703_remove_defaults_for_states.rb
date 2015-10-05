class RemoveDefaultsForStates < ActiveRecord::Migration
  def change
    change_column_default(:orders, :state, nil)
    change_column_default(:orders, :payment_state, nil)
  end
end
