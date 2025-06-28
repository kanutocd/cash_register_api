class CartItem < ApplicationRecord
  belongs_to :product

  validates :product_id, uniqueness: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def total_price
    fetch_promo_perk(:total) || product.price * quantity
  end

  def discount_price
    fetch_promo_perk(:discount) || 0
  end

  def free_quantity
    fetch_promo_perk(:free_items) || 0
  end

  private

  # Returns the current promo for the product this cart item refers to,
  # memoized so that it's not fetched multiple times.
  def current_promo
    @current_promo ||= product.current_promo
  end

  def fetch_promo_perk(amount_type)
    current_promo&.apply_discount(quantity, product.price)&.fetch(amount_type)
  end
end
