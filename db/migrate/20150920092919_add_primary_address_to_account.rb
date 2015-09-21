class AddPrimaryAddressToAccount < ActiveRecord::Migration
  def change
    add_reference :accounts, :primary_address, index: true
    add_foreign_key :accounts, :addresses, column: :primary_address_id
  end
end
