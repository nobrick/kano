class AddCheckColumnToWithdrawal < ActiveRecord::Migration
  def change
    add_column :withdrawals, :verify_passed, :boolean
  end
end
