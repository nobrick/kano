class AddAuditStateToWithdrawals < ActiveRecord::Migration
  def change
    remove_column(:withdrawals, :verify_passed, :boolean)
    add_column(:withdrawals,
               :audit_state,
               :string,
               default: 'unaudited',
               limit: 20)
    add_index(:withdrawals, :audit_state)
  end
end
