class RemoveHandymanFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :handyman, :boolean
  end
end
