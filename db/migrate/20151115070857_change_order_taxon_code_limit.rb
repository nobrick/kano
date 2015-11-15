class ChangeOrderTaxonCodeLimit < ActiveRecord::Migration
  def change
    change_column :orders, :taxon_code, :string, limit: 128
  end
end
