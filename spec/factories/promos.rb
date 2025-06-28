FactoryBot.define do
  factory :promo do
    product
    name { Faker::Commerce.promotion_code }
    promo_type { Promo::PROMO_TYPES.sample }
    trigger_qty { Faker::Number.between(from: 1, to: 10) }
    free_qty { promo_type == "buy_x_get_y_free" ? Faker::Number.between(from: 1, to: 5) : nil }
    discount_percentage { promo_type == "percentage_discount" ? Faker::Number.between(from: 1, to: 50) : nil }
    discount_amount { promo_type == "fixed_discount" ? Faker::Commerce.price(range: 1..20) : nil }
    active { true }

    trait :buy_x_get_y_free do
      promo_type { "buy_x_get_y_free" }
    end

    trait :percentage_discount do
      promo_type { "percentage_discount" }
    end

    trait :fixed_discount do
      promo_type { "fixed_discount" }
    end
  end
end
