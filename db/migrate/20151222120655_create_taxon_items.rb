class CreateTaxonItems < ActiveRecord::Migration
  def up
    create_table :taxon_items do |t|
      t.string :code, limit: 128, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.string :city, limit: 20
      t.string :brief

      t.timestamps null: false
    end
    add_index :taxon_items, [ :city, :code ], unique: true
    Rake::Task['db:init_prices'].invoke
  end

  def down
    remove_index :taxon_items, [ :city, :code ]
    drop_table :taxon_items
  end
end
