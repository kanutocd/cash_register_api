class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :products, :code, unique: true
    add_index :products, :name, unique: true
    add_index :products, :active
  end
end
