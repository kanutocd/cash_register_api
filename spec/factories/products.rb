FactoryBot.define do
  factory :product do
    code { Faker::Alphanumeric.alphanumeric(number: 10, min_alpha: 3) }
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence(word_count: 10) }
    price { Faker::Commerce.price(range: 1..100) }
    active { true }
  end
end
