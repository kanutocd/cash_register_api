class Promo < ApplicationRecord
  PROMO_TYPES = %w[buy_x_get_y_free percentage_discount fixed_discount].freeze

  belongs_to :product

  validates :name, presence: true, uniqueness: { scope: :product_id, case_sensitive: false }
  validates :promo_type, presence: true, inclusion: { in: PROMO_TYPES }
  validates :trigger_qty, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validates :free_qty,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            if: -> { promo_type == "buy_x_get_y_free" },
            allow_nil: true
  validates :discount_percentage,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            if: -> { promo_type == "percentage_discount" },
            allow_nil: true
  validates :discount_amount,
            numericality: { greater_than_or_equal_to: 0 },
            if: -> { promo_type == "fixed_discount" },
            allow_nil: true

  scope :active, -> { where(active: true) }

  def apply_discount(quantity, unit_price)
    if !active? || quantity < trigger_qty || Promo::PROMO_TYPES.exclude?(promo_type)
      return { total: quantity * unit_price, discount: 0, quantity: }
    end

    case promo_type
    when "buy_x_get_y_free"
      apply_buy_x_get_y_free(quantity, unit_price)
    when "percentage_discount"
      apply_percentage_discount(quantity, unit_price)
    when "fixed_discount"
      apply_fixed_discount(quantity, unit_price)
    end
  end

  private

  def apply_buy_x_get_y_free(quantity, unit_price)
    free_items = (quantity / trigger_qty) * free_qty

    { total: quantity * unit_price, discount: free_items * unit_price, quantity: quantity + free_items }
  end

  def apply_percentage_discount(quantity, unit_price)
    discount = (quantity * unit_price) * (discount_percentage / 100.0)
    total = (quantity * unit_price) - discount
    { total:, discount:, quantity: }
  end

  def apply_fixed_discount(quantity, unit_price)
    discount = quantity * discount_amount
    total = (quantity * unit_price) - discount
    { total:, discount:, quantity: }
  end
end
