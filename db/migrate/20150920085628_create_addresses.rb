class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true, null: false, index: true
      t.string :province, limit: 20, null: false
      t.string :city, limit: 20, null: false
      t.string :district, limit: 20, null: false
      t.string :code, limit: 10, null: false
      t.string :content, null: false

      t.timestamps null: false
    end
    add_index :addresses, [ :province, :city, :district ]
    add_index :addresses, :code
  end
end
