class AddUniqueIndexToRequestedWithdrawals < ActiveRecord::Migration
  def change
    add_index :withdrawals,
      :handyman_id,
      unique: true,
      where: "state = 'requested'",
      name: 'index_requested_withdrawals_on_handyman_id'
  end
end
