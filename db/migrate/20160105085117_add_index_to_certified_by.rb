class AddIndexToCertifiedBy < ActiveRecord::Migration
  def change
    add_index :taxons, :certified_by
  end
end
