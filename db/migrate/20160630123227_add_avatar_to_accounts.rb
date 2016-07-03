class AddAvatarToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :avatar, :string
  end
end
