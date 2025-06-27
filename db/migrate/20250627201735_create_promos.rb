class CreatePromos < ActiveRecord::Migration[8.0]
  def change
    create_table :promos do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.string :promo_type, null: false
      t.integer :trigger_qty, null: false, default: 1
      t.integer :free_qty
      t.decimal :discount_percentage, precision: 5, scale: 2
      t.decimal :discount_amount, precision: 10, scale: 2
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :promos, %i[product_id name], unique: true
    add_index :promos, :active
    add_index :promos, :promo_type
  end
end
