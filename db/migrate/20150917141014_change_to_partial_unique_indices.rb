class ChangeToPartialUniqueIndices < ActiveRecord::Migration
  def up
    remove_index :accounts, :email
    remove_index :accounts, :phone
    add_index :accounts, :email,              unique: true, where: 'email is not null'
    add_index :accounts, :phone,              unique: true, where: 'phone is not null'
    add_index :accounts, [ :provider, :uid ], unique: true, where: 'uid is not null'
  end

  def down
    remove_index :accounts, :email
    remove_index :accounts, :phone
    remove_index :accounts, [ :provider, :uid ]
    add_index :accounts, :email, unique: true
    add_index :accounts, :phone, unique: true
  end
end
