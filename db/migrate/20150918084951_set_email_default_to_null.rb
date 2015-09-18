class SetEmailDefaultToNull < ActiveRecord::Migration
  def change
    change_column_default :accounts, :email, nil
  end
end
