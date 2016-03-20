class ChangeVerifyTypeInWithdrawal < ActiveRecord::Migration
  def up
    change_column :withdrawals, :verify_passed, :string, default: 'unverified'
  end

  def down
    change_column_default :withdrawals, :verify_passed, nil
    change_column :withdrawals, :verify_passed, 'boolean USING CAST(verify_passed AS boolean)'
  end
end
