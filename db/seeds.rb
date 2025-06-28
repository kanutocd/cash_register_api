# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

products_data = [
  { code: "GR1", name: 'Green Tea', description: 'Fresh yellow-greenish tea leaves', price: 3.11 },
  { code: "SR1",
    name: 'Strawberries',
    description: 'Freshly picked strawberries which are the only botanical berries in the whole known universe.',
    price: 5.00 },
  { code: "CF1",
    name: 'Coffee',
    description: 'Freshly roasted coffee berries. Coffee should have title Coffeeberries.',
    price: 11.23 }
]

products = products_data.map do |data|
  Product.find_or_create_by(code: data[:code]) do |product|
    product.name = data[:name]
    product.description = data[:description]
    product.price = data[:price]
  end
end

promos_data = [
  {
    product_code: 'GR1',
    name: 'Buy 1 Get 1 Free',
    promo_type: 'buy_x_get_y_free',
    trigger_qty: 1,
    free_qty: 1
  },
  {
    product_code: 'CF1',
    name: '33.33% Off on 3 or more',
    promo_type: 'percentage_discount',
    trigger_qty: 3,
    discount_percentage: 15.0
  },
  {
    product_code: 'SR1',
    name: '€0.50 Off on 3 or more',
    promo_type: 'fixed_discount',
    trigger_qty: 3,
    discount_amount: 0.50
  }
]

promos_data.each do |data|
  product = Product.find_by(code: data[:product_code])
  next unless product

  Promo.find_or_create_by(
    product: product,
    name: data[:name]
  ) do |promotion|
    promotion.promo_type = data[:promo_type]
    promotion.trigger_qty = data[:trigger_qty]
    promotion.free_qty = data[:free_qty]
    promotion.discount_percentage = data[:discount_percentage]
    promotion.discount_amount = data[:discount_amount]
  end
end

puts "Seeded #{Product.count} products and #{Promo.count} promos"
