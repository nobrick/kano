class AddNotNullConstraintToWithdrawalAuditState < ActiveRecord::Migration
  def change
    change_column_null(:withdrawals, :audit_state, false)
  end
end
