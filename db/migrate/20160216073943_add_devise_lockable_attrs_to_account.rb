class AddDeviseLockableAttrsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :locked_at, :datetime
  end
end
