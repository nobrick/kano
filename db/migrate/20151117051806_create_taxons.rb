class CreateTaxons < ActiveRecord::Migration
  def change
    create_table :taxons do |t|
      t.references :handyman, index: true,  null: false
      t.string :code, limit: 128, null: false

      t.timestamps null: false
    end
    add_foreign_key :taxons, :accounts, column: :handyman_id
    add_index :taxons, :code
  end
end
