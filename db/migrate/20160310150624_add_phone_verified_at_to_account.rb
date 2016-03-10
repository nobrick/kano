class AddPhoneVerifiedAtToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :phone_verified_at, :datetime
    add_index :accounts, :phone_verified_at
  end
end
