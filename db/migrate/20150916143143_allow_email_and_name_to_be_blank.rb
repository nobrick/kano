class AllowEmailAndNameToBeBlank < ActiveRecord::Migration
  def change
    change_column_null :accounts, :email, true
    change_column_null :accounts, :name, true
  end
end
