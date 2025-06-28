# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_27_224820) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cart_items", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id_unique", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["code"], name: "index_products_on_code", unique: true
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "promos", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "name", null: false
    t.string "promo_type", null: false
    t.integer "trigger_qty", default: 1, null: false
    t.integer "free_qty"
    t.decimal "discount_percentage", precision: 5, scale: 2
    t.decimal "discount_amount", precision: 10, scale: 2
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_promos_on_active"
    t.index ["product_id", "name"], name: "index_promos_on_product_id_and_name", unique: true
    t.index ["product_id"], name: "index_promos_on_product_id"
    t.index ["promo_type"], name: "index_promos_on_promo_type"
  end

  add_foreign_key "cart_items", "products"
  add_foreign_key "promos", "products"
end
