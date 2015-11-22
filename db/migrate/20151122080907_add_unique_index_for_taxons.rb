class AddUniqueIndexForTaxons < ActiveRecord::Migration
  def up
    remove_index :taxons, :code
    add_index :taxons, [ :handyman_id, :code ], unique: true
  end

  def down
    remove_index :taxons, [ :handyman_id, :code ]
    add_index :taxons, :code
  end
end
