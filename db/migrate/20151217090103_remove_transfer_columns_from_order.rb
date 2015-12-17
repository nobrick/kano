class RemoveTransferColumnsFromOrder < ActiveRecord::Migration
  def change
    remove_column :orders, :transfer_type, :string
    remove_column :orders, :transfer_reason, :string
    remove_column :orders, :transferred_at, :datetime
    remove_column :orders, :transferee_order_id, :integer
    remove_column :orders, :transferor_id, :integer
  end
end
