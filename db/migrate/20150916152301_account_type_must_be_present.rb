class AccountTypeMustBePresent < ActiveRecord::Migration
  def change
    change_column_null :accounts, :type, false
  end
end
